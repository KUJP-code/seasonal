# frozen_string_literal: true

class RashimbaInquiriesController < ApplicationController
  before_action :authenticate_user!
  before_action -> { authorize RashimbaInquiry }
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    inquiries = %i[filter_kind filter_status filter_query].reduce(
      policy_scope(RashimbaInquiry).latest_first
    ) { |scope, filter| send(filter, scope) }
    @rashimba_inquiries = inquiries.page(params[:page]).per(25)
  end

  def show
    @rashimba_inquiry = policy_scope(RashimbaInquiry).find(params[:id])
  end

  def update
    @rashimba_inquiry = policy_scope(RashimbaInquiry).find(params[:id])
    if @rashimba_inquiry.update(params.require(:rashimba_inquiry).permit(:status, :admin_notes))
      redirect_to rashimba_inquiry_path(@rashimba_inquiry), notice: 'Inquiry updated.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    policy_scope(RashimbaInquiry).find(params[:id]).destroy!
    redirect_to rashimba_inquiries_path, notice: 'Inquiry deleted.', status: :see_other
  end

  private

  def filter_kind(scope)
    return scope unless RashimbaInquiry::KINDS.value?(params[:kind])

    scope.where(kind: params[:kind])
  end

  def filter_status(scope)
    return scope unless RashimbaInquiry.statuses.key?(params[:status])

    scope.where(status: params[:status])
  end

  def filter_query(scope)
    return scope if params[:q].blank?

    query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.strip.first(200))}%"
    scope.where('email ILIKE :q OR name ILIKE :q OR company ILIKE :q', q: query)
  end
end
