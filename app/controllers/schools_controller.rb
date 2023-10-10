# frozen_string_literal: true

# Handles data flow for Schools
class SchoolsController < ApplicationController
  def show
    @school = School.find(params[:id])
  end

  def new
    @areas = Area.all
  end

  def edit
    @school = School.find(params[:id])
    @areas = Area.all
  end

  def update
    @school = School.find(params[:id])

    if @school.update(school_params)
      redirect_to school_path(@school), notice: "Updated #{@school.name}!"
    else
      render :edit, status: unprocessable_entity,
                    alert: "Couldn't update #{@school.name}"
    end
  end

  private

  def school_params
    params.require(:school).permit(
      :name, :address, :phone, :area_id, :nearby_stations, :bus_areas
    )
  end
end
