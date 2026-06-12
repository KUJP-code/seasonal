# frozen_string_literal: true

module Api
  class PhotoServiceController < ApplicationController
    skip_before_action :verify_authenticity_token

    def login
      result = PhotoService::LoginService.new.login(params[:code].to_s)

      render_login_result(result)
    rescue PhotoService::ConfigurationError => e
      render_configuration_error(e)
    rescue StandardError => e
      Rails.logger.error("[photo_service] login failed: #{e.class}: #{e.message}")
      render json: { success: false, message: 'An error occurred' },
             status: :internal_server_error
    end

    def pictures
      files = PhotoService::DriveClient.new.pictures_in_folder(params[:folder_id])

      if files.empty?
        render json: { success: false, message: 'No pictures found' },
               status: :not_found
      else
        render json: { files: }
      end
    rescue PhotoService::ConfigurationError => e
      render_configuration_error(e)
    rescue StandardError => e
      Rails.logger.error("[photo_service] pictures failed: #{e.class}: #{e.message}")
      render json: { success: false, message: 'An error occurred' },
             status: :internal_server_error
    end

    def seasonal_pictures
      activities = PhotoService::SeasonalPicturesService.new.call(
        seasonal_pictures_params[:activities] || []
      )

      if activities.empty?
        render json: { success: false, message: 'No valid activities found' },
               status: :not_found
      else
        render json: activities
      end
    rescue PhotoService::ConfigurationError => e
      render_configuration_error(e)
    rescue StandardError => e
      Rails.logger.error("[photo_service] seasonal pictures failed: #{e.class}: #{e.message}")
      render json: { success: false, message: 'An error occurred' },
             status: :internal_server_error
    end

    private

    def render_login_result(result)
      return render json: result if result[:success]

      render json: { success: false, message: result[:message] },
             status: :unauthorized
    end

    def render_configuration_error(error)
      Rails.logger.error("[photo_service] #{error.message}")
      render json: { success: false, message: 'Photo service is not configured' },
             status: :service_unavailable
    end

    def seasonal_pictures_params
      params.permit(activities: %i[date name folder_id])
    end
  end
end
