# frozen_string_literal: true

class SetsumeikaisController < ApplicationController
  def index
    @schools = policy_scope(School)
    @school = params[:school] ? School.find(params[:school]) : @schools.first
    @setsumeikais = index_setsumeikais
    @setsumeikai = params[:setsumeikai] ? setsu_from_params : default_setsu
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

  def default_setsu
    Setsumeikai.new(school_id: @school.id,
                    setsumeikai_involvements_attributes: [{ school_id: @school.id }])
  end

  def index_setsumeikais
    setsumeikais = current_user.school_manager? ? policy_scope(Setsumeikai) : @school.all_setsumeikais
    setsumeikais.includes(:school, :involved_schools)
                .order(start: :desc)
                .page(params[:page])
  end

  def setsu_from_params
    Setsumeikai.new(setsumeikai_params)
  end
end
