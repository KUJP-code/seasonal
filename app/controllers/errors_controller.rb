# Controls error messages
class ErrorsController < ApplicationController
  def permission
    @user = current_user
  end
end
