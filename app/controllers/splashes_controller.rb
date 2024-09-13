# frozen_string_literal: true

# Finds the latest splash images for the welcome/login pages
class SplashesController < ApplicationController
  include BlobFindable

  def landing
    @fallback = latest_splash_upload('image/png')
    @avif = latest_splash_upload('image/avif')
  end
end
