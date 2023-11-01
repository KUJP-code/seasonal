# frozen_string_literal: true

class SheetsApisController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :inquiries

  def schools
    schools = School.real.select(:id, :name, :email).order(id: :desc)
    response = {
      statusCode: 200,
      message: 'ok',
      results: schools.map(&:to_gas_api)
    }
    render json: response
  end

  def inquiries
    school = School.find_by(name: inquiries_params[:schoolName])
    inquiries = school.inquiries.where(send_flg: true).includes(:setsumeikai)

    response = {
      statusCode: 200,
      message: 'ok',
      results: inquiries.map(&:to_gas_api),
      counts: inquiries.size
    }
    render json: response
  end

  def update; end

  private

  def inquiries_params
    params.permit(:schoolName)
  end
end
