# frozen_string_literal: true

# Facilitates import/export of records for certain models
class CsvsController < ApplicationController
  def index; end

  def download
    model = params[:model].constantize
    path = "/tmp/#{params[:model].downcase.pluralize}#{Time.zone.now.strftime('%Y%m%d%H%M')}.csv"

    File.open(path, 'wb') do |f|
      model.copy_to do |line|
        f.write line
      end
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def upload
    csv = params[:csv]
    model = params[:model].constantize

    model.copy_from(csv.tempfile.path) do |row|
      row[9] = Time.zone.now
      row[10] = Time.zone.now
    end

    redirect_to csvs_path, notice: "#{params[:model].capitalize} records imported."
  end
end
