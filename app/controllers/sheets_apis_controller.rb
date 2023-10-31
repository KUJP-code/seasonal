# frozen_string_literal: true

class SheetsApisController < ApplicationController
  def schools
    schools = School.real.select(:id, :name, :email).order(id: :desc)
    response = {
      statusCode: 200,
      message: 'ok',
      results: schools.map { |s| { school_name: s.name, email: s.email || '' } }
    }
    respond_to do |f|
      f.json { render json: response }
    end
  end

  def inquiries; end

  def update_sent; end
end
