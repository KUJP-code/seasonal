# frozen_string_literal: true

class AdjustmentsController < ApplicationController
  def edit
    @invoice = Invoice.find(params[:id])
  end
end
