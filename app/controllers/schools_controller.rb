# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :set_school, only: %i[destroy edit show update]
  after_action :verify_authorized, except: %i[index]

  def index
    # just force json response from kids-up.jp to fix enquiry bugs
    if request.referer&.include?('kids-up.jp')
      json_index
    else
      respond_to do |f|
        f.html { html_index }
        f.json { json_index }
      end
    end
  end

  def show; end

  def new
    @school = authorize School.new
    form_data
  end

  def edit
    form_data
  end

  def create
    @school = authorize School.new(permitted_attributes(School))

    if @school.save
      redirect_to school_path(@school), notice: "Created #{@school.name}!"
    else
      form_data
      render :new, status: :unprocessable_entity,
                   alert: "Couldn't create #{@school.name}"
    end
  end

  def update
    if @school.update(permitted_attributes(@school))
      changing_position = permitted_attributes(@school)['position'].present?
      url = changing_position ? schools_url : school_url(@school)

      redirect_to url, notice: "Updated #{@school.name}!"
    else
      form_data
      render :edit, status: :unprocessable_entity,
                    alert: "Couldn't update #{@school.name}"
    end
  end

  def destroy
    if @school.destroy
      redirect_to areas_path, notice: "Deleted #{@school.name}"
    else
      redirect_to school_path(@school),
                  alert: "Couldn't delete #{@school.name}. Check it has no children"
    end
  end

  private

  def form_data
    @managers = User.school_managers
    @areas = Area.all
    @images = ActiveStorage::Blob.where('key LIKE ?', '%schools%')
                                 .map { |blob| [blob.key, blob.id] }
  end

  def html_index
    @schools = policy_scope(School).order(position: :asc)
  end

  def json_index
    @schools = School.real.order(id: :desc).includes(calendar_setsumeikais: %i[school])
    render json: School.all
  end

  def set_school
    @school = authorize School.find(params[:id])
  end
end
