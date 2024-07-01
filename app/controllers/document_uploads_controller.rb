# frozen_string_literal: true

class DocumentUploadsController < ApplicationController
  after_action :verify_authorized, only: %i[index]

  def index
    authorize DocumentUpload
    @schools = policy_scope(School).order(:id) if current_user.admin? || current_user.area_manager?
    set_school
    @document_uploads = policy_scope(DocumentUpload)
                        .where(school_id: @school.id)
                        .order(created_at: :desc)
                        .includes(document_attachment: :blob)
  end

  def show; end

  def new
    @document_upload = DocumentUpload.new
    @schools = School.real.order(:id).pluck(:name, :id)
  end

  def create
    @document_upload = DocumentUpload.new(document_upload_params)

    if @document_upload.save
      DocumentUploadMailer.with(document_upload: @document_upload)
                          .sm_notification
                          .deliver_later
      redirect_to @document_upload, notice: '書類を受け取りました'
    else
      @schools = School.real.order(:id).pluck(:name, :id)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def document_upload_params
    params.require(:document_upload).permit(:category, :child_name, :document, :school_id)
  end

  def set_school
    default_school = @schools ? @schools.first : current_user.managed_school
    @school = params[:school] ? School.find(params[:school]) : default_school
    authorize @school, :show?
  end
end
