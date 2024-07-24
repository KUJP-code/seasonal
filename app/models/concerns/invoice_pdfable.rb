# frozen_string_literal: true

module InvoicePdfable
  extend ActiveSupport::Concern
  require 'prawn/measurement_extensions'

  included do
    def pdf
      pdf = create_pdf_object
      pdf_header(pdf)
      pdf_summary(pdf)
      pdf_footer(pdf)
      pdf.render
    end
  end

  private

  def create_pdf_object
    pdf = Prawn::Document.new
    pdf.font_families.update(
      'NotoSans' => {
        normal: { file: Rails.root.join('app/assets/fonts/NotoSansJP-Medium.ttf'),
                  subset: false }
      }
    )
    pdf.font('NotoSans')
    pdf.define_grid(columns: 20, rows: 20, gutter: 0)
    pdf
  end

  def pdf_footer(pdf)
    tax = yenify(0.1 * total_cost)
    without_tax = yenify(0.9 * total_cost)

    # Tax box
    pdf.grid([18, 0], [18, 2]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 29.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('税率区分', align: :center, color: 'ffffff') }
    end

    pdf.grid([18, 3], [18, 5]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 29.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('消費税', align: :center, color: 'ffffff') }
    end

    pdf.grid([18, 6], [18, 8]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 29.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('金額（税抜）', align: :center, color: 'ffffff') }
    end

    pdf.grid([19, 0], [19, 2]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text('10%対象', align: :center, color: '000000') }
    end

    pdf.grid([19, 3], [19, 5]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(tax, align: :center, color: '000000') }
    end

    pdf.grid([19, 6], [19, 8]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(without_tax, align: :center, color: '000000') }
    end

    # Summary box
    pdf.grid([17, 12], [17, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 38.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('小計', align: :center, color: 'ffffff') }
    end

    pdf.grid([18, 12], [18, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 38.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('消費税', align: :center, color: 'ffffff') }
    end

    pdf.grid([19, 12], [19, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 38.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('合計', align: :center, color: 'ffffff') }
    end

    pdf.grid([17, 16], [17, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(without_tax, align: :center, color: '000000') }
    end

    pdf.grid([18, 16], [18, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(tax, align: :center, color: '000000') }
    end

    pdf.grid([19, 16], [19, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(yenify(total_cost), align: :center, color: '000000') }
    end
  end

  def pdf_header(pdf)
    # Title
    pdf.grid([0, 0], [1, 19]).bounding_box do
      pdf.fill_color '2864f0'
      pdf.fill_rectangle(pdf.bounds.top_left, 191.mm, 1.cm)
      pdf.pad(1.mm) { pdf.text('請求書', align: :center, color: 'ffffff', size: 20) }
    end

    # Total Cost
    pdf.grid([1, 0], [1, 9]).bounding_box do
      pdf.pad(2.mm) { pdf.text("#{child.parent.name}様", size: 20, color: '000000') }
    end
    pdf.grid([2, 0], [2, 9]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 95.mm, 13.mm)
      pdf.pad(3.mm) { pdf.text('金額（税込）', align: :center, color: 'ffffff', size: 20) }
    end
    pdf.grid([3, 0], [3, 9]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(3.mm) { pdf.text(yenify(total_cost), align: :right, color: '000000', size: 20) }
    end

    # Date & Registration number
    pdf.grid([1, 11], [2, 19]).bounding_box do
      pdf.text("発行日: #{Time.zone.now.strftime('%F')}", align: :right, color: '000000')
    end

    # Company Info
    pdf.grid([2, 11], [4, 19]).bounding_box do
      pdf.text("株式会社Kids-UP\n" \
               "〒120-0034\n" \
               "住所：東京都足立区千住\n" \
               "1-4-1東京芸術センター11階\n" \
               "電話：03-3870-0099\n",
               align: :right,
               color: '000000',
               leading: 1.mm,
               size: 11)
    end
  end

  def pdf_options(pdf)
    pdf.move_down(2.mm)
    pdf.text('オプション', color: '000000')
    pdf.move_down(2.mm)
    pdf.text(options.group(:name)
                    .count
                    .map { |k, v| "#{k} x #{v}" }
                    .join("\n"),
             color: '000000',
             leading: 1.mm,
             size: 8)
  end

  def pdf_slots(pdf)
    pdf.move_down(2.mm)
    pdf.text('コース', color: '000000')
    pdf.move_down(2.mm)
    pdf.text(time_slots.sort_by(&:start_time).map(&:name_date).join("\n"),
             color: '000000',
             leading: 1.mm,
             size: 8)
  end

  def pdf_summary(pdf)
    pdf.grid([4, 0], [16, 19]).bounding_box do
      pdf.stroke_bounds
    end

    pdf.grid([4, 0], [7, 12]).bounding_box do
      pdf.stroke_bounds
    end

    pdf.grid([4, 13], [7, 15]).bounding_box do
      pdf.stroke_bounds
    end

    # Headers
    # Contents
    pdf.grid([4, 0], [4, 12]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 124.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('内容', align: :center, color: 'ffffff') }
    end

    # Quantity
    pdf.grid([4, 13], [4, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 30.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('数量', align: :center, color: 'ffffff') }
    end

    # Total Cost
    pdf.grid([4, 16], [4, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.fill_rectangle(pdf.bounds.top_left, 38.mm, 13.mm)
      pdf.pad(4.mm) { pdf.text('金額（税抜）', align: :center, color: 'ffffff') }
    end

    # Summary Names
    # Adjustments
    pdf.grid([5, 0], [5, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.indent(1.mm) do
        pdf.pad(4.mm) { pdf.text('調整', color: '000000', size: 14) }
      end
    end

    # Options
    pdf.grid([6, 0], [6, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.indent(1.mm) do
        pdf.pad(4.mm) { pdf.text('オプション', color: '000000', size: 14) }
      end
    end

    # Courses
    pdf.grid([7, 0], [7, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.indent(1.mm) do
        pdf.pad(4.mm) { pdf.text('コース', color: '000000', size: 14) }
      end
    end

    # Summary Quantities
    # Adjustments
    pdf.grid([5, 13], [5, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(adjustments.size.to_s, align: :center, color: '000000', size: 14) }
    end

    # Options
    pdf.grid([6, 13], [6, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(opt_regs.size.to_s, align: :center, color: '000000', size: 14) }
    end

    # Courses
    pdf.grid([7, 13], [7, 15]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) { pdf.text(slot_regs.size.to_s, align: :center, color: '000000', size: 14) }
    end

    # Summary Costs
    # Adjustments
    pdf.grid([5, 16], [5, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) do
        pdf.text(yenify(adjustments.sum(:change)), align: :center, color: '000000', size: 14)
      end
    end

    # Options
    pdf.grid([6, 16], [6, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) do
        pdf.text(yenify(options.sum(:cost)), align: :center, color: '000000', size: 14)
      end
    end

    # Courses
    pdf.grid([7, 16], [7, 19]).bounding_box do
      pdf.stroke_bounds
      pdf.pad(4.mm) do
        pdf.text(yenify(calc_course_cost(time_slots)),
                 align: :center, color: '000000', size: 14)
      end
    end

    # Course Details
    pdf.grid([8, 0], [16, 19]).bounding_box do
      pdf.column_box([0, pdf.cursor], columns: 3, width: pdf.bounds.width,
                                      height: pdf.bounds.height) do
        pdf.indent(2.mm) do
          pdf_adj(pdf) unless adjustments.empty?
          pdf_options(pdf) unless options.empty?
          pdf_slots(pdf)
        end
      end
    end
  end

  def pdf_adj(pdf)
    pdf.move_down(2.mm)
    pdf.text('調整', color: '000000')
    pdf.move_down(2.mm)
    pdf.text(adjustments.map(&:reason_cost).join("\n"),
             color: '000000',
             leading: 1.mm,
             size: 8)
  end
end
