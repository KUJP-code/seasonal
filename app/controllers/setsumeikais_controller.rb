# frozen_string_literal: true

# Handles information flow for Setsumeikais
class SetsumeikaisController < ApplicationController
  def index
    @setsumeikais = policy_scope(Setsumeikai).upcoming
                                             .order(start: :desc)
  end

  def show
    @setsumeikai = authorize(Setsumeikai.find(params[:id]))
    @inquiries = @setsumeikai.inquiries
  end

  def new
    @setsumeikai = Setsumeikai.new
    @schools = policy_scope(School)
  end

  def edit
    @setsumeikai = authorize(Setsumeikai.find(params[:id]))
    @schools = policy_scope(School)
  end

  def create
    @setsumeikai = Setsumeikai.new(setsumeikai_params)

    if @setsumeikai.save
      redirect_to setsumeikais_path,
                  notice: 'Created setsumeikai'
    else
      @schools = policy_scope(School)
      render :new,
             status: :unprocessable_entity,
             alert: 'Failed to create setsumeikai'
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
      :id, :finish, :start, :attendance_limit, :school_id
    )
  end
end
