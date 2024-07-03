# frozen_string_literal: true

class DocumentUploadsController < ApplicationController
  layout 'unauthenticated', except: :index

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
    @schools = School.order(id: :desc).pluck(:name, :id)
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

  def destroy
    @document_upload = DocumentUpload.find(params[:id])

    if @document_upload.destroy
      redirect_to document_uploads_url(school: @document_upload.school_id),
                  notice: t('success', model: '書類', action: '削除')
    else
      redirect_to document_uploads_url(school: @document_upload.school_id),
                  alert: t('failure', model: '書類', action: '削除')
    end
  end

  private

  def document_upload_params
    params.require(:document_upload).permit(
      :category, :child_name, :document, :other_description, :school_id
    )
  end

  def set_school
    default_school = @schools ? @schools.first : current_user.managed_school
    @school = params[:school] ? School.find(params[:school]) : default_school
    authorize @school, :show?
  end
end
