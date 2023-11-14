# frozen_string_literal: true

class SetsumeikaisController < ApplicationController
  def index
    @schools = policy_scope(School)
    @setsumeikais = if current_user.admin? || current_user.area_manager?
                      admin_index
                    else
                      policy_scope(Setsumeikai).upcoming
                                               .includes(
                                                 :school,
                                                 :involved_schools
                                               )
                                               .order(start: :desc)
                                               .page(params[:page])
                    end
    @setsumeikai = Setsumeikai.new
  end

  def show
    @setsumeikai = authorize(Setsumeikai.find(params[:id]))
    @inquiries = @setsumeikai.inquiries
  end

  def edit
    @setsumeikai = authorize(Setsumeikai.find(params[:id]))
    @schools = policy_scope(School)
  end

  def create
    @setsumeikai = Setsumeikai.new(setsumeikai_params)

    if @setsumeikai.save
      redirect_to setsumeikais_path(school: @setsumeikai.school_id),
                  notice: "Created #{@setsumeikai.school.name} setsumeikai"
    else
      @schools = policy_scope(School)
      redirect_to setsumeikais_path(school: @setsumeikai.school_id),
                  alert: @setsumeikai.errors.full_messages.join(', ')
    end
  end

  def update
    @setsumeikai = authorize(Setsumeikai.find(params[:id]))

    if @setsumeikai.update(setsumeikai_params)
      redirect_to setsumeikai_path(@setsumeikai),
                  notice: "Updated #{@setsumeikai.school.name} setsumeikai"
    else
      @schools = policy_scope(School)
      render :edit,
             status: :unprocessable_entity,
             alert: @setsumeikai.errors.full_messages.join(', ')
    end
  end

  private

  def setsumeikai_params
    params.require(:setsumeikai).permit(
      :id, :start, :attendance_limit, :school_id, :release_date, setsumeikai_involvements_attributes: %i[
        id setsumeikai_id school_id _destroy
      ]
    )
  end

  def admin_index
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @school.all_setsumeikais
           .includes(:school, :involved_schools)
           .page(params[:page])
  end
end
