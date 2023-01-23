# frozen_string_literal: true

# Control flow of data for Children
class ChildrenController < ApplicationController
  def index
    return find_child if params[:commit] == 'Find Child'

    if params[:source]
      @source = find_source
      child_list

      return render "#{@source.class.name.downcase}_index"
    end

    @children = index_for_role
  end

  def show
    @child = Child.find(params[:id]) unless params[:id].nil?
  end

  private

  def child_list
    @attending = @source.children.distinct
    @not_attending = @source.school.children.reject { |c| @attending.include?(c) }
  end

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

  def find_child
    @child = search_result
    render 'users/_add_child', locals: { parent: User.find(params[:parent_id]) }
  end

  def search_result
    Child.find_by(ssid: params[:ssid], birthday: params[:bday])
  end

  def find_source
    case params[:source]
    when 'Event'
      Event.find(params[:id])
    when 'TimeSlot'
      TimeSlot.find(params[:id])
    end
  end

  def index_for_role
    return Child.all if current_user.admin?
    return current_user.area_children if current_user.area_manager?
    return current_user.school_children if current_user.school_manager?
  end
end
