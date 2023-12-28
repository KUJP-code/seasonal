# frozen_string_literal: true

class SetsumeikaisController < ApplicationController
  before_action :set_setsumeikai, only: %i[destroy edit show update]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    authorize Setsumeikai
    @schools = policy_scope(School).order(:id)
    school_given = params[:school] && params[:school] != '0'
    @school = school_given ? School.find(params[:school]) : default_school
    @setsumeikais = index_setsumeikais
    @setsumeikai = params[:setsumeikai] ? setsu_from_params : default_setsu
  end

  def show
    @inquiries = @setsumeikai.inquiries
  end

  def edit
    @schools = policy_scope(School)
  end

  def create
    @setsumeikai = authorize Setsumeikai.new(setsumeikai_params)

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

  def destroy
    if @setsumeikai.destroy
      redirect_to setsumeikais_path,
                  notice: t('success', model: '説明会', action: '消去')
    else
      redirect_to setsumeikais_path,
                  alert: t('failure',  model: '説明会', action: '消去')
    end
  end

  private

  def setsumeikai_params
    params.require(:setsumeikai).permit(
      :id, :start, :attendance_limit, :school_id, :release_date, :close_at,
      setsumeikai_involvements_attributes: %i[id setsumeikai_id school_id _destroy]
    )
  end

  def default_school
    if current_user.school_manager?
      @schools.first
    else
      School.new(id: 0)
    end
  end

  def default_setsu
    Setsumeikai.new(school_id: @school.id,
                    setsumeikai_involvements_attributes: [{ school_id: @school.id }])
  end

  def index_setsumeikais
    scoped_setsu = policy_scope(Setsumeikai)
                   .joins(:setsumeikai_involvements)
                   .distinct
                   .includes(:involved_schools, :school)
                   .order(start: :desc)
                   .page(params[:page])

    return scoped_setsu if @school.id.zero?

    scoped_setsu.where(setsumeikai_involvements: { school_id: @school.id })
  end

  def set_setsumeikai
    @setsumeikai = authorize Setsumeikai.find(params[:id])
  end

  def setsu_from_params
    Setsumeikai.new(setsumeikai_params)
  end
end
