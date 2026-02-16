# frozen_string_literal: true

class RecruitTrackingLinksController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize RecruitTrackingLink

    @recruit_tracking_link = RecruitTrackingLink.new
    @recruit_tracking_links = policy_scope(RecruitTrackingLink).active.latest_first.page(params[:page])
  end

  def create
    slug = recruit_tracking_link_params[:slug].to_s.strip.downcase
    @recruit_tracking_link = RecruitTrackingLink.find_or_initialize_by(slug:)
    authorize @recruit_tracking_link, @recruit_tracking_link.new_record? ? :create? : :update?

    @recruit_tracking_link.assign_attributes(name: recruit_tracking_link_params[:name], active: true)
    if @recruit_tracking_link.save
      redirect_to recruit_tracking_links_path,
                  notice: 'Tracking link saved'
    else
      @recruit_tracking_links = policy_scope(RecruitTrackingLink).active.latest_first.page(params[:page])
      render :index, status: :unprocessable_entity
    end
  end

  def remove
    @recruit_tracking_link = authorize RecruitTrackingLink.find(params[:id])
    @recruit_tracking_link.update!(active: false)
    redirect_to recruit_tracking_links_path,
                notice: 'Tracking link removed'
  end

  private

  def recruit_tracking_link_params
    params.require(:recruit_tracking_link).permit(:name, :slug)
  end
end
