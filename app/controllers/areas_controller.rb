# frozen_string_literal: true

class AreasController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Area
    @areas = policy_scope(Area).includes(
      :managers, schools: %i[image_attachment managers]
    )
  end

  def show
    @area = authorize Area.find(params[:id])
  end

  def new
    @area = authorize Area.new
    @managers = User.area_managers
  end

  def edit
    @area = authorize Area.find(params[:id])
    @managers = User.area_managers
  end

  def create
    @area = authorize Area.new(area_params)

    if @area.save
      redirect_to area_path(@area), notice: "Created #{@area.name}!"
    else
      render :new, status: unprocessable_entity,
                   alert: "Couldn't create #{@area.name}"
    end
  end

  def update
    @area = authorize Area.find(params[:id])

    if @area.update(area_params)
      redirect_to area_path(@area), notice: "Updated #{@area.name}!"
    else
      render :edit, status: unprocessable_entity,
                    alert: "Couldn't update #{@area.name}"
    end
  end

  private

  def area_params
    params.require(:area).permit(
      :name, managements_attributes:
        %i[id manageable_id manageable_type manager_id _destroy]
    )
  end
end
