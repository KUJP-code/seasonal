# frozen_string_literal: true

class Invoice < ApplicationRecord
  include InvoicePdfable
  include InvoiceCalculatable

  before_save :update_regs_child, :calc_cost

  belongs_to :child
  delegate :parent, to: :child
  delegate :school, to: :child
  belongs_to :event

  has_many :registrations, dependent: :destroy
  accepts_nested_attributes_for :registrations
  has_many :slot_regs, -> { where(registerable_type: 'TimeSlot') },
           class_name: 'Registration',
           dependent: :destroy,
           inverse_of: :invoice
  accepts_nested_attributes_for :slot_regs, allow_destroy: true
  has_many :opt_regs, -> { where(registerable_type: 'Option') },
           class_name: 'Registration',
           dependent: :destroy,
           inverse_of: :invoice
  accepts_nested_attributes_for :opt_regs, allow_destroy: true,
                                           reject_if: :orphan_option?
  has_many :time_slots, through: :slot_regs,
                        source: :registerable,
                        source_type: 'TimeSlot'
  has_many :options, through: :opt_regs,
                     source: :registerable,
                     source_type: 'Option'
  has_many :adjustments, dependent: :destroy
  accepts_nested_attributes_for :adjustments, allow_destroy: true
  has_many :coupons, as: :couponable,
                     dependent: :destroy
  accepts_nested_attributes_for :coupons, reject_if: :blank_or_dup

  # Track changes with Paper Trail
  has_paper_trail unless: proc { |t| t.in_ss || t.seen_at || t.entered || t.email_sent }

  # Allow export/import with postgres-copy
  acts_as_copy_target

  # Scopes
  # Only invoices with at least one time slot registered
  scope :real, -> { where('registrations_count > 0') }

  # Validations
  validates :total_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def id_and_cost
    "##{id}, #{yenify(total_cost)}"
  end

  private

  def generate_details
    @breakdown.prepend(
      "<div class='d-flex gap-3 flex-column align-items-start'>\n
      <h2 class='fw-semibold'>#{child.name}</h2>\n
      <h4 class-'fw-semibold'>#{child.kindy ? '幼児' : '小学生'}</h4>\n
      <h4 class-'fw-semibold'>#{case child.category
                                when 'internal'
                                  '通学生'
                                when 'reservation'
                                  '予約生'
                                else
                                  '非会員'
                                end}</h4>\n
      <h3 class='fw-semibold'>#{event.name} @ #{event.school.name}</h3>\n"
    )
    @breakdown << "</div><h2 class='fw-semibold text-start'>お申込内容:</h2>\n"

    e_opt_regs = opt_regs.where(registerable: event.options)
    unless e_opt_regs.empty?
      @breakdown << "<h4 class='fw-semibold text-start'>イベントのオプション:</h4>\n"
      @breakdown << '<div class="d-flex gap-3 p-3 justify-content-start flex-wrap">'
      event.options.each do |opt|
        @breakdown << "<p>- #{opt.name}: #{yenify(opt.cost)}</p>\n"
      end
      @breakdown << '</div>'
    end

    @breakdown << "<h4 class='fw-semibold text-start'>登録</h4>\n"
    @breakdown << '<div class="d-flex flex-column gap-3 p-3 justify-content-start flex-wrap">'
    slot_regs.sort_by { |r| r.registerable.start_time }.each do |slot_reg|
      next if @ignore_slots.include?(slot_reg.id)

      slot = slot_reg.registerable

      @breakdown << if slot.morning
                      "<div class='slot_regs d-flex flex-wrap gap-3 text-start'><h5>#{slot.name} (#{slot.date})</h5>\n"
                    else
                      "<div class='slot_regs d-flex flex-wrap gap-3 text-start'><h5>#{slot.name} (#{slot.date}) (午後)</h5>\n"
                    end

      # Show details for all registered options, even unsaved
      opt_regs.select { |reg| slot.options.ids.include?(reg.registerable_id) }.each do |opt_reg|
        next if opt_reg.nil? || @ignore_opts.include?(opt_reg.id)

        opt = opt_reg.registerable
        next if opt.name == 'なし'

        @breakdown << "<p> - #{opt.name}: #{yenify(opt.cost)}</p>\n"
      end
      @breakdown << '</div>'
    end
    @breakdown << '</div>'
  end

  # Remove options where the slot is no longer registered for
  def orphan_option?(opt_reg)
    return true if slot_regs.empty?
    # Exclude event options from the check
    return false if event.options.ids.include?(opt_reg['registerable_id'].to_i)

    option = Option.find(opt_reg['registerable_id'])
    # If for special day extension, only delete if neither registered
    if option.extension? || option.k_extension?
      return slot_regs.none? do |r|
               r.registerable.special?
             end
    end

    slot_regs.none? { |s_reg| s_reg.registerable_id == option.optionable_id }
  end

  def update_regs_child
    return if slot_regs.empty? || slot_regs.first.child_id == child_id

    registrations.each do |reg|
      reg.update!(child_id:)
    end
  end

  def yenify(number)
    "#{number.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円"
  end
end
