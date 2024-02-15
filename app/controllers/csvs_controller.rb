# frozen_string_literal: true

class CsvsController < ApplicationController
  ALLOWED_MODELS = %w[Child Invoice RegularSchedule Setsumeikai TimeSlot User].freeze

  def index
    authorize(:csv)
  end

  def download
    authorize(:csv)
    model = params[:model].constantize if ALLOWED_MODELS.include?(params[:model])
    model_name = params[:model].downcase.pluralize if ALLOWED_MODELS.include?(params[:model])
    path = "/tmp/#{model_name}#{Time.zone.now.strftime('%Y%m%d%H%M')}.csv"

    File.open(path, 'wb') do |f|
      if params[:event]
        event_ids = Event.where(name: params[:event]).ids

        model.where(event_id: event_ids).copy_to do |line|
          f.write line
        end
      else
        model.copy_to do |line|
          f.write line
        end
      end
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def update
    authorize(:csv)
    csv = params[:csv]

    if params[:model] == 'Child'
      update_child(csv)
    elsif params[:model] == 'Setsumeikai'
      update_setsumeikai(csv)
    else
      update_schedule(csv)
    end

    redirect_to csvs_path, notice: "#{params[:model] if ALLOWED_MODELS.include?(params[:model])} records updated."
  end

  def upload
    authorize(:csv)
    csv = params[:csv]
    model = params[:model].constantize if ALLOWED_MODELS.include?(params[:model])
    time = Time.zone.now

    model.copy_from(csv.tempfile.path) do |row|
      # Data from the SS doesn't come with created_at/updated_at, so we
      # need to set them ourselves
      row[12] = time
      row[13] = time
    end

    redirect_to csvs_path, notice: "#{params[:model] if ALLOWED_MODELS.include?(params[:model])} records imported."
  end

  private

  # Find the child from provided SSID and set their child_id/
  # remove ssid from the hash
  def get_child_id(row)
    child_id = Child.find_by(ssid: row['ssid']).id
    row['child_id'] = child_id
    row.delete('ssid')
    child_id
  end

  # Some SS data is missing required fields, so we need to set default values
  def defaults(row)
    row['name'] = 'なし' if row['name'].nil?
    row['katakana_name'] = 'ナシ' if row['katakana_name'].nil?
    row['en_name'] = 'なし' if row['en_name'].nil?
    row['birthday'] = 'なし' if row['birthday'].nil?
    row['allergies'] = 'Unknown' if row['allergies'].nil?
    row['photos'] = 'NG' if row['photos'].nil?
  end

  # The CSV method doesn't accept int values for enums, so we need to
  # translate to the string values
  def translate_enums(row)
    row['category'] = Child.categories.key(row['category'].to_i)
    row['grade'] = Child.grades.key(row['grade'].to_i)
    row['photos'] = Child.photos.key(row['photos'].to_i)
  end

  # Update Child records if present, otherwise create new ones
  def update_child(csv)
    CSV.foreach(csv.tempfile.path, headers: true) do |row|
      translate_enums(row)
      defaults(row)

      if Child.find_by(ssid: row['ssid'])
        Child.find_by(ssid: row['ssid']).update!(row.to_hash)
      else
        Child.create!(row.to_hash)
      end
    end
  end

  def update_setsumeikai(csv)
    CSV.foreach(csv.tempfile.path, headers: true) do |row|
      hash = row.to_h

      Setsumeikai.create!(
        hash.merge(
          setsumeikai_involvements_attributes: [{ school_id: hash['school_id'] }]
        )
      )
    end
  end

  # Update Schedule records if present, otherwise create new ones
  def update_schedule(csv)
    CSV.foreach(csv.tempfile.path, headers: true) do |row|
      child_id = get_child_id(row)

      if Child.find(child_id)&.regular_schedule.nil?
        Child.find(child_id).create_regular_schedule(row.to_hash)
      else
        RegularSchedule.find_by(child_id: child_id).update!(row.to_hash)
      end
    end
  end
end
