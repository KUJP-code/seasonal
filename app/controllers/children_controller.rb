# frozen_string_literal: true

# Control flow of data for Children
class ChildrenController < ApplicationController
  def index
    if params[:commit] == 'Find Child'
      @child = search_result
      return render 'users/_add_child', locals: { parent: User.find(params[:parent_id]) }
    end
    @children = index_for_role
  end

  def show
    @child = Child.find(params[:id]) unless params[:id].nil?
  end

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

  def search_result
    Child.find_by(ssid: params[:ssid], birthday: params[:bday])
  end

  def index_for_role
    return Child.all if current_user.admin?
    return current_user.school_children if current_user.school_manager?
    return current_user.area_children if current_user.area_manager?
  end
end
