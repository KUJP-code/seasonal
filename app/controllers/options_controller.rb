# frozen_string_literal: true

# Controls flow of information for Options
class OptionsController < ApplicationController
  def create
    @option = Option.new(opt_params)

    if @option.save
      flash[:notice] = t('.success', option: @option.name)
      redirect_back_or_to child_path(@option.child)
    else
      flash.now[:alert] = t('.failure')
    end
  end

  def destroy
    @option = Option.find(params[:id])

    if @option.destroy
      flash[:notice] = t('.success', option: @option.name)
      redirect_back_or_to child_path(@option.child)
    else
      flash.now[:alert] = t('.failure')
    end
  end

  private

  def opt_params
    params.require(:option).permit(:id, :name, :description, :cost, :time_slot_id)
  end
end
