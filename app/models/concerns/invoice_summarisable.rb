# frozen_string_literal: true

module InvoiceSummarisable
  extend ActiveSupport::Concern

  included do
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
  end
end
