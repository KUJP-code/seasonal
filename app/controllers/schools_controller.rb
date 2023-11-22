# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :set_school, only: %i[edit show update]

  def index
    @schools = School.real.order(id: :desc).includes(calendar_setsumeikais: %i[school])
    respond_to do |f|
      f.json { render json: @schools }
    end
  end

  def show; end

  def new
    @school = School.new
    form_data
  end

  def edit
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
      :hiragana, :image_id, :email, managements_attributes:
        %i[id manageable_id manageable_type manager_id _destroy]
    )
  end

  def form_data
    @managers = User.school_managers
    @areas = Area.all
    @images = ActiveStorage::Blob.where('key LIKE ?', '%schools%')
                                 .map { |blob| [blob.key, blob.id] }
  end

  def set_school
    @school = School.find(params[:id])
  end
end
