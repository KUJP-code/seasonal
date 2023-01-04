# frozen_string_literal: true

# Represents the relationship between managers and their school/area
class Management < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :manageable, polymorphic: true
end
