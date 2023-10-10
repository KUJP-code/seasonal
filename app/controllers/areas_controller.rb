# frozen_string_literal: true

# Handles data flow for Schools
class AreasController < ApplicationController
  def index
    @areas = policy_scope(Area).includes(:managers, :schools)
  end
end
