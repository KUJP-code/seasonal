# frozen_string_literal: true

# Facilitates import/export of records for certain models
class CsvsController < ApplicationController
  def index; end

  def download
    model = params[:model].constantize
    path = "/tmp/#{params[:model].downcase}.csv"

    File.open(path, 'wb') do |f|
      model.copy_to do |line|
        f.write line
      end
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def upload
    # csv = params[:csv]
  end
end
