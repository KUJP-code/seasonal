# frozen_string_literal: true

class AreasController < ApplicationController
  before_action :set_area, only: %i[destroy edit show update]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Area
    @areas = policy_scope(Area).includes(
      :managers, schools: %i[image_attachment managers]
    )
  end

  def show; end

  def new
    @area = authorize Area.new
    @managers = User.area_managers
  end

  def edit
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
    if @area.update(area_params)
      redirect_to area_path(@area), notice: "Updated #{@area.name}!"
    else
      render :edit, status: unprocessable_entity,
                    alert: "Couldn't update #{@area.name}"
    end
  end

  def destroy
    if @area.destroy
      redirect_to areas_path, notice: "Deleted #{@area.name}"
    else
      redirect_to area_path(@area),
                  alert: "Couldn't delete #{@area.name}. Check it has no schools"
    end
  end

  private

  def area_params
    params.require(:area).permit(
      :name, managements_attributes:
        %i[id manageable_id manageable_type manager_id _destroy]
    )
  end

  def set_area
    @area = authorize Area.find(params[:id])
  end
end
