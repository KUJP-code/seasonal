# frozen_string_literal: true

# Controller for Adjustments
class AdjustmentsController < ApplicationController
  def edit
    authorize :adjustment, :edit?
    @invoice = Invoice.find(params[:id])
  end
end
