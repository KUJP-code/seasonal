# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include BlobFindable
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    def new
      @fallback = latest_splash_upload('image/png')
      @avif = latest_splash_upload('image/avif')
      super
    end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
