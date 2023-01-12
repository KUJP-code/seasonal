# frozen_string_literal: true

# Control flow of data for Children
class ChildrenController < ApplicationController
  private

  def child_params
    params.require(:child).permit(:id, :ja_first_name, :ja_family_name,
                                  :katakana_name, :en_name, :category,
                                  :birthday, :level, :allergies, :ssid,
                                  :ele_school_name, :post_photos, :needs_hat,
                                  :received_hat, :parent_id, :school_id,
                                  registrations_attributes: %i[
                                    cost child_id registerable_type
                                    registerable_id
                                  ])
  end
end
