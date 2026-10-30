# frozen_string_literal: true

class Invoice < ApplicationRecord
  include InvoiceCalculatable
  include InvoicePdfable
  include InvoiceSummarisable

  before_save :update_regs_child
  before_save :assign_pricing_batches
  before_save :calc_cost, unless: :in_ss?
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
  # Only invoices with at least one time slot/option registered
  scope :real, -> { where('registrations_count > 0') }
  scope :for_registration_page,
        lambda { |event|
          where(event_id: event)
            .includes(:adjustments, :opt_regs, :registrations,
                      :slot_regs, :time_slots)
        }

  # Validations
  validates :total_cost,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def calc_cost
    remove_ineligible_photo_service
    assign_pricing_batches
    generate_data
    self.total_cost = @data[:total_cost]
    self.summary = generate_summary(@data)
    @data
  end

  def id_and_cost
    "##{id}, #{yenify(total_cost)}"
  end

  def photo_service_eligible?
    own_slot_ids = validated_slot_regs.map(&:registerable_id)
    return true if TimeSlot.where(id: own_slot_ids, event_id:).photo_service_eligible.exists?
    return false unless child_id && event_id

    other_slots = child.time_slots.where(event_id:)
    other_slots = other_slots.where.not(registrations: { invoice_id: id }) if id.present?
    other_slots.photo_service_eligible.exists?
  end

  def sync_photo_service_with_siblings!
    return unless event.pricing_rules_2026?

    photo_option_ids = event.options.where(category: :event).pluck(:id)
    return if photo_option_ids.empty?

    siblings = child.siblings + [child]
    eligible_siblings = siblings.select do |sibling|
      if event.seasonal?
        sibling.photo_service_eligible_for?(event)
      else
        sibling.time_slots.exists?(event:)
      end
    end
    current_has_photo = child.invoices.where(event:)
                             .joins(:opt_regs)
                             .exists?(registrations: {
                               registerable_type: 'Option',
                               registerable_id: photo_option_ids
                             })

    sync_eligible_siblings = eligible_siblings.include?(child)

    siblings.each do |sibling|
      next if eligible_siblings.include?(sibling) && !sync_eligible_siblings

      invoices = sibling.invoices.where(event:).includes(:time_slots, :slot_regs, :opt_regs).to_a
      target_invoice = invoices.find do |inv|
        if event.seasonal?
          inv.time_slots.any? { |slot| slot.morning? || slot.special? }
        else
          inv.slot_regs.any?
        end
      end
      target_invoice ||= invoices.first
      next unless target_invoice

      existing_regs = invoices.flat_map(&:opt_regs).select do |reg|
        photo_option_ids.include?(reg.registerable_id)
      end

      updated = false
      if current_has_photo && eligible_siblings.include?(sibling)
        if existing_regs.empty?
          target_invoice.opt_regs.create!(
            child: sibling,
            registerable_id: photo_option_ids.first,
            registerable_type: 'Option'
          )
          updated = true
        end
      elsif existing_regs.any?
        existing_regs.each(&:destroy)
        updated = true
      end

      next unless updated

      target_invoice.reload
      target_invoice.calc_cost
      target_invoice.save!
    end
  end

  def recalculate_pricing!
    transaction do
      slot_regs.update_all(pricing_batch: 1) if event.pricing_rules_2026?
      reload
      calc_cost
      save!
    end
  end

  private

  def remove_ineligible_photo_service
    photo_regs = opt_regs.reject(&:marked_for_destruction?).select do |reg|
      reg.registerable.photo_service?
    end
    return if photo_regs.empty? || photo_service_eligible?

    photo_regs.each(&:mark_for_destruction)
  end

  def blank_or_dup(coupon)
    return true if coupon['code'].empty? || coupons.map(&:code).include?(coupon['code'])

    false
  end

  def update_regs_child
    return if slot_regs.empty? || slot_regs.first.child_id == child_id

    registrations.each do |reg|
      reg.update!(child_id:)
    end
  end

  def assign_pricing_batches
    return unless event&.pricing_rules_2026?

    new_slot_regs = slot_regs.select do |reg|
      reg.id.blank? && !reg.marked_for_destruction?
    end
    return if new_slot_regs.empty?

    persisted_slot_regs = slot_regs.reject { |reg| reg.id.blank? }
    replacement_batches = persisted_slot_regs.select(&:marked_for_destruction?)
                                             .map(&:pricing_batch)
                                             .compact

    existing_batches = persisted_slot_regs.map(&:pricing_batch)
    next_batch = existing_batches.compact.max.to_i + 1
    next_batch = 1 if existing_batches.empty?

    new_slot_regs.each do |reg|
      reg.pricing_batch = replacement_batches.shift || next_batch
    end
  end
end
