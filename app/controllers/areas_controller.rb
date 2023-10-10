# frozen_string_literal: true

# Handles data flow for Schools
class AreasController < ApplicationController
  def index
    @areas = policy_scope(Area).includes(:managers, :schools)
  end

  def show
    @area = Area.find(params[:id])
  end

  def new
    @area = Area.new
  end

  def edit
    @area = Area.find(params[:id])
  end

  def create
    @area = Area.new(area_params)

    if @area.save
      redirect_to area_path(@area), notice: "Created #{@area.name}!"
    else
      render :new, status: unprocessable_entity,
                   alert: "Couldn't create #{@area.name}"
    end
  end

  def update
    @area = Area.find(params[:id])

    if @area.update(area_params)
      redirect_to area_path(@area), notice: "Updated #{@area.name}!"
    else
      render :edit, status: unprocessable_entity,
                    alert: "Couldn't update #{@area.name}"
    end
  end

  private

  def area_params
    params.require(:area).permit(:name)
  end
end
