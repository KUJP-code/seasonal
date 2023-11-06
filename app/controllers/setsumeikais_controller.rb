# frozen_string_literal: true

class SetsumeikaisController < ApplicationController
  def index
    @schools = policy_scope(School).order(:id)
    return admin_index if current_user.admin?

    @setsumeikais = policy_scope(Setsumeikai).upcoming
                                             .order(start: :desc)
                                             .page(params[:page])
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
                  notice: 'Created setsumeikai'
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
      render :edit,
             status: :unprocessable_entity,
             alert: "Failed to update #{@setsumeikai.school.name} setsumeikai"
    end
  end

  private

  def setsumeikai_params
    params.require(:setsumeikai).permit(
      :id, :start, :attendance_limit, :school_id, setsumeikai_involvements_attributes: %i[
        id setsumeikai_id school_id _destroy
      ]
    )
  end

  def admin_index
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @setsumeikais = @school.setsumeikais.upcoming
  end
end
