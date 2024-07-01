# frozen_string_literal: true

class DocumentUploadsController < ApplicationController
  after_action :verify_authorized, only: %i[index]

  def index
    authorize DocumentUpload
    @document_uploads = policy_scope DocumentUpload
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
end
