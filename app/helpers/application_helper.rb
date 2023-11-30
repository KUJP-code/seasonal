# frozen_string_literal: true

module ApplicationHelper
  # Needed in both User and Child controllers:w
  def full_address(user)
    "#{t('.address')}: #{user.prefecture}, #{user.address}, #{user.postcode}"
  end
end
