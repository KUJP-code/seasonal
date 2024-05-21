# frozen_string_literal: true

module InvoiceSummarisable
  extend ActiveSupport::Concern

  included do
    private

    def generate_summary(data)
      @breakdown = +''
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
      @breakdown << '</div>'
      unless data[:num_regs].zero?
        @breakdown <<
          "<h4 class='fw-semibold'>コース:</h4>
        <div class='d-flex flex-column align-items-start gap-1'>
        <p>#{yenify(data[:course_cost])} (#{data[:num_regs]}回)</p>
        #{data[:course_summary]}"
        if data[:extra_cost_count].positive?
          @breakdown << "<p>追加料金 x #{data[:extra_cost_count]}: #{yenify(data[:extra_cost])}</p>"
        end
        if data[:snack_count].positive?
          @breakdown << "<p>午後コースおやつ代 x #{data[:snack_count]}: #{yenify(data[:snack_cost])}</p>"
        end
        @breakdown << '</div>'
      end

      if data[:options].size.positive?
        @breakdown << "<h4 class='fw-semibold'>オプション:</h4>
                     <div class='d-flex flex-column align-items-start gap-1'>
                     <p>#{yenify(data[:opt_cost])} (#{data[:options].size}オプション)<p>"
      end
      @breakdown << '</div>'

      e_opt_regs = opt_regs.where(registerable: event.options)
      unless e_opt_regs.empty?
        @breakdown << "<h4 class='fw-semibold text-start'>イベントのオプション:</h4>\n"
        @breakdown << '<div class="d-flex gap-3 p-3 justify-content-start flex-wrap">'
        event.options.each do |opt|
          @breakdown << "<p>- #{opt.name}: #{yenify(opt.cost)}</p>\n"
        end
        @breakdown << '</div>'
      end

      # Display options with count and cost
      per_name_costs = data[:options].group(:name).sum(:cost)
      data[:options].group(:name).count.each do |name, count|
        @breakdown << "<p>- #{name} x #{count}: #{yenify(per_name_costs[name])}</p>"
      end

      if adjustments.size.positive?
        @breakdown << '<h4 class="fw-semibold text-start">調整:</h4>'
        @breakdown << '<div class="d-flex flex-column align-items-start gap-1">'
        adjustments.each do |adj|
          @breakdown << "<p>#{adj.reason}: #{yenify(adj.change)}</p>"
        end
        @breakdown << '</div>'
      end

      @breakdown << "<h2 class='fw-semibold text-start'>お申込内容:</h2>\n"
      @breakdown << "<h4 class='fw-semibold text-start'>登録</h4>\n"
      @breakdown << '<div class="d-flex flex-column gap-3 p-3 justify-content-start flex-wrap">'
      data[:time_slots].order(start_time: :desc).each do |slot|
        @breakdown << if slot.morning
                        "<div class='slot_regs d-flex flex-wrap gap-3 text-start'><h5>#{slot.name} (#{slot.date})</h5>\n"
                      else
                        "<div class='slot_regs d-flex flex-wrap gap-3 text-start'><h5>#{slot.name} (#{slot.date}) (午後)</h5>\n"
                      end

        # Show details for all registered options, even unsaved
        slot_options = slot.options.ids
        data[:options].select { |opt| slot_options.include?(opt.id) }.each do |opt|
          next if opt.name == 'なし'

          @breakdown << "<p> - #{opt.name}: #{yenify(opt.cost)}</p>\n"
        end
        @breakdown << '</div>'
      end
      @breakdown << '</div>'
      @breakdown << "<h2 id='final_cost' class='fw-semibold text-start'>合計（税込）: #{yenify(data[:total_cost])}</h2>\n"
    end

    def yenify(number)
      "#{number.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}円"
    end
  end
end
