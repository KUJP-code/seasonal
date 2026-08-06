# frozen_string_literal: true

class ChildImportJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 250
  MAX_REPORTED_ERRORS = 200

  def perform(import)
    import.update!(status: 'processing', started_at: Time.current)
    import.source_file.open { |file| process_file(import, file.path) }
    import.reload
    finish(import, import.failed_count.positive? ? 'completed_with_errors' : 'completed')
  rescue StandardError => e
    add_error(import, nil, e.message)
    finish(import, 'failed')
  end

  private

  def process_file(import, path)
    encoding, separator = file_format(path)
    parser = SsChildRowParser.new
    headers = CSV.open(path, "rb:#{encoding}:UTF-8", headers: true, col_sep: separator) do |csv|
      csv.first&.headers&.map { |header| header&.delete_prefix("\uFEFF") }
    end
    validate_headers!(headers)
    import.update!(total_rows: count_rows(path, encoding, separator))

    CSV.open(path, "rb:#{encoding}:UTF-8", headers: true, col_sep: separator) do |csv|
      csv.each_slice(BATCH_SIZE) { |rows| process_batch(import, rows, parser) }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def process_batch(import, rows, parser)
    counters = {
      processed_rows: 0, created_count: 0, updated_count: 0,
      unchanged_count: 0, skipped_count: 0, failed_count: 0
    }
    errors = []

    rows.each do |row|
      process_row(row, parser, counters)
    rescue SsChildRowParser::SkippedRow
      counters[:skipped_count] += 1
    rescue StandardError => e
      counters[:failed_count] += 1
      errors << { row: import.processed_rows + counters[:processed_rows] + 2, message: e.message }
    ensure
      counters[:processed_rows] += 1
    end

    import.with_lock do
      counters.each { |field, amount| import[field] += amount }
      import.error_details = (import.error_details + errors).first(MAX_REPORTED_ERRORS)
      import.save!
    end
  end
  # rubocop:enable Metrics/AbcSize

  def process_row(row, parser, counters)
    attributes = parser.call(row)
    child = Child.find_or_initialize_by(ssid: attributes[:ssid])
    new_record = child.new_record?
    child.assign_attributes(attributes)

    if !child.changed?
      counters[:unchanged_count] += 1
    elsif child.save
      counters[new_record ? :created_count : :updated_count] += 1
    else
      raise ActiveRecord::RecordInvalid, child
    end
  end

  def file_format(path)
    bytes = File.binread(path, 16_384)
    encoding = bytes.dup.force_encoding(Encoding::UTF_8).valid_encoding? ? 'UTF-8' : 'Windows-31J'
    sample = bytes.encode(
      Encoding::UTF_8, encoding, invalid: :replace, undef: :replace
    )
    first_line = sample.lines.first.to_s
    separator = first_line.count("\t") > first_line.count(',') ? "\t" : ','
    [encoding, separator]
  end

  def validate_headers!(headers)
    missing = SsChildRowParser::REQUIRED_HEADERS - Array(headers)
    raise ArgumentError, "Missing SS columns: #{missing.join(', ')}" if missing.any?
  end

  def count_rows(path, encoding, separator)
    CSV.foreach(path, encoding: "#{encoding}:UTF-8", headers: true, col_sep: separator).count
  end

  def add_error(import, row, message)
    return unless import&.persisted?

    details = import.error_details + [{ row:, message: }]
    import.update!(error_details: details.first(MAX_REPORTED_ERRORS))
  end

  def finish(import, status)
    import&.update!(status:, finished_at: Time.current)
  end
end
