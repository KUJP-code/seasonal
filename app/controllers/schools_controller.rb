# frozen_string_literal: true

# Handles data flow for Schools
class SchoolsController < ApplicationController
  def show
    @school = School.find(params[:id])
  end

  def new
    @school = School.new
    form_data
  end

  def edit
    @school = School.find(params[:id])
    form_data
  end

  def create
    @school = School.new(school_params)

    if @school.save
      redirect_to school_path(@school), notice: "Created #{@school.name}!"
    else
      render :new, status: unprocessable_entity,
                   alert: "Couldn't create #{@school.name}"
    end
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
      :name, :address, :phone, :area_id, :nearby_stations, :bus_areas,
      managements_attributes:
        %i[id manageable_id manageable_type manager_id _destroy]
    )
  end

  def form_data
    @managers = User.school_managers
    @areas = Area.all
  end
end
