# frozen_string_literal: true

# Controls error messages
class ErrorsController < ApplicationController
  def permission
    @user = current_user
  end

  def registration_error; end
  def required_user; end
end
