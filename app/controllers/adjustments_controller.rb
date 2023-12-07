# frozen_string_literal: true

class AdjustmentsController < ApplicationController
  after_action :verify_authorized

  def edit
    authorize :adjustment, :edit?
    @invoice = Invoice.find(params[:id])
  end
end
