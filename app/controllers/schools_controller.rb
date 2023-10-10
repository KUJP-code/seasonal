# frozen_string_literal: true

# Handles data flow for Schools
class SchoolsController < ApplicationController
  def edit
    @school = School.find(params[:id])
  end
end
