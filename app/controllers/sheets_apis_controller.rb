# frozen_string_literal: true

class SheetsApisController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[inquiries update]

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

  def update
    @inquiries = inquiries_from_update_params
    toggle_send_flags

    response = {
      statusCode: 200,
      message: update_error? ? 'error' : 'ok',
      results: update_error? ? 'error' : 'ok',
      process: 'HPデータ連携',
      total: @param_ids.size,
      r_success: @r_success,
      i_success: @i_success,
      detail: @inquiries.map(&:to_gas_update)
    }
    render json: response
  end

  private

  def inquiries_params
    params.permit(:schoolName)
  end

  def update_params
    params.permit(:update)
  end

  def inquiries_from_update_params
    param_inquries = Oj.safe_load(update_params[:update].tr('\\', ''))
    @param_ids = param_inquries.pluck('id').map(&:to_i)
    Inquiry.where(id: @param_ids).includes(:setsumeikai)
  end

  def toggle_send_flags
    @r_success = 0
    @i_success = 0
    @inquiries.each do |i|
      next @r_success += 1 if i.category == 'R' && i.update(send_flg: false)

      @i_success += 1 if i.update(send_flg: false)
    end
  end

  def update_error?
    return true if @inquiries.size < @param_ids.size
    return true unless @r_success + @i_success == @inquiries.size

    false
  end
end
