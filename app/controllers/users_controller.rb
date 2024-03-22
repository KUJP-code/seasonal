# frozen_string_literal: true

class UsersController < ApplicationController
  after_action :verify_authorized, except: %i[add_child profile]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize User
    return new_users if params[:ids]

    @users = policy_scope(User).customer
                               .includes(:children)
                               .page(params[:page]).per(50)
    @users = @users.where(search_params) if params[:search]
  end

  def profile
    redirect_to user_path(current_user)
  end

  def show
    @user = authorize User.find(params[:id])
    send("#{@user.role}_data", @user)
    render "users/#{@user.role}"
  end

  def new
    @user = authorize User.new
  end

  def edit
    @user = authorize User.find(params[:id])
  end

  def create
    @user = authorize User.new(user_params)

    if @user.save
      redirect_to user_path(@user),
                  notice: t('success', model: '保護者', action: '追加')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('failure', model: '保護者', action: '追加')
    end
  end

  def update
    @user = authorize User.find(params[:id])

    if @user.update(user_params)
      redirect_to user_path(@user),
                  notice: t('success', model: '保護者', action: '更新')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('failure', model: '保護者', action: '更新')
    end
  end

  def add_child
    @child = Child.find(params[:child_id])

    if @child.update(
      parent_id: params[:parent_id],
      first_seasonal: params[:first_seasonal]
    )
      redirect_to child_path(@child),
                  notice: t('success', model: '生徒', action: '更新')
    else
      redirect_to user_path(current_user),
                  alert: t('failure', model: '生徒', action: '更新')
    end
  end

  def merge_children
    ss_kid = authorize(Child.find(params[:ss_kid]), :show?)
    non_ss_kid = authorize(Child.find(params[:non_ss_kid]), :show?)

    merge_info(non_ss_kid, ss_kid)
    non_ss_kid.reload.destroy

    redirect_to child_path(ss_kid),
                notice: t('success', model: '生徒', action: '更新')
  end

  private

  def admin_data(_user)
    @recent_bookings = Invoice.real
                              .order(created_at: :desc)
                              .limit(5).includes(:child)
    @upcoming_events = Event.upcoming.real.includes(
      :children, :options, :school
    ).group_by(&:name)
    @managers = User.where(role: %i[school_manager area_manager]).order(:id)
  end

  def already_registered?(t_regs, o_reg)
    t_regs.any? do |t_reg|
      t_reg.registerable_id == o_reg.registerable_id && t_reg.registerable_type == o_reg.registerable_type
    end
  end

  def area_manager_data(user)
    @managed_areas = user.managed_areas.includes(upcoming_events: %i[children])
    school_ids = @managed_areas.reduce([]) { |arr, a| arr.push(a.schools.ids) }
                               .flatten
    @area_events = Event.upcoming.real
                        .where(school_id: school_ids)
                        .includes(
                          :options,
                          :school,
                          :children
                        ).group_by(&:name)
    @upcoming_events = Event.upcoming.real.includes(:children).group_by(&:name)
    @managers = user.area_school_managers
  end

  def copy_invoices(from, to)
    if to.invoices.empty?
      move_invoices(from, to)
    else
      merge_invoices(from, to)
    end
  end

  def customer_data(user)
    @children = user.children.includes(:school)
    @invoices = user.real_invoices
    return if @children.empty?

    @events = @children.first
                       .school.events
                       .upcoming.reorder(start_date: :desc)
  end

  def delete_admin?
    @user.admin? && User.admins.size <= 1
  end

  def find_equivalent_id(option)
    return option.id unless %w[arrival k_arrival departure k_departure extension k_extension].include?(option.category)

    # Switch the category to the correct one for target's kindy/elementary
    category = option.category
    equivalent_category = if category.start_with?('k_')
                            category.gsub('k_', '')
                          else
                            "k_#{category}"
                          end

    # Find and return the equivalent option's id
    option.optionable.options.find_by(name: option.name, category: equivalent_category).id
  end

  def merge_info(from, to)
    to.update(parent_id: from.parent_id, first_seasonal: from.first_seasonal)
    to.update(school_id: from.school_id) if to.school_id.nil?
    to.survey_responses << from.survey_responses
    copy_invoices(from, to)
    from.update(parent_id: nil)
  end

  def merge_invoices(from, to)
    from_regs = from.invoices.map(&:registrations).flatten
    to_regs = to.invoices.map(&:registrations).flatten
    to_active_invoice = to.invoices.where(in_ss: false).order(created_at: :desc).first ||
                        to.invoices.create(event_id: from.invoices.first.event_id)

    from_regs.each do |reg|
      # Skip if already registered
      next if already_registered?(to_regs, reg)

      # Check the created and SS child are same level, adjust options if not
      registerable_id = if reg.registerable_type == 'Option' && from.kindy != to.kindy
                          find_equivalent_id(reg.registerable)
                        else
                          reg.registerable_id
                        end

      # Else associate reg with to child and their open invoice
      reg.update(child_id: to.id, invoice_id: to_active_invoice.id, registerable_id: registerable_id)
    end

    # Update the newly merged invoice
    to_active_invoice.reload && to_active_invoice.save
  end

  def move_invoices(from, to)
    from.invoices.each do |invoice|
      # Change the child associated with the invoice
      invoice.update(child_id: to.id)
      # Same for each registration on the invoice
      invoice.registrations.each do |reg|
        # Check the created and SS child are same level, adjust options if not
        registerable_id = if reg.registerable_type == 'Option' && from.kindy != to.kindy
                            find_equivalent_id(reg.registerable)
                          else
                            reg.registerable_id
                          end

        reg.update(child_id: to.id, registerable_id: registerable_id)
      end
      # Update the invoice to reflect its new owner
      invoice.reload && invoice.save
    end
  end

  def new_users
    @users = if current_user.admin?
               policy_scope(User.where(id: params[:ids])).page(params[:page]).per(500)
             else
               policy_scope(User.where(id: params[:ids]))
             end
  end

  def school_manager_data(user)
    @school = user.managed_school
    @upcoming_events = @school.upcoming_events.includes(
      :children, :invoices, :time_slots
    )
    sm_upcoming_events_data(@upcoming_events.ids, user)
  end

  def sm_deleted_invoices(user, event_ids)
    PaperTrail::Version.where(
      whodunnit: user.id,
      event: 'destroy',
      item_type: 'Invoice'
    )
                       .order(created_at: :desc)
                       .filter_map(&:reify)
                       .reject { |i| i.total_cost.zero? }
                       .select { |i| event_ids.include?(i.event_id) }
  end

  def sm_upcoming_events_data(event_ids, user)
    @deleted_invoices = sm_deleted_invoices(user, event_ids)
    @recent_bookings = Invoice.real
                              .where(event_id: event_ids)
                              .order(created_at: :desc)
                              .limit(5)
                              .includes(:child)
  end

  def statistician_data(user)
    admin_data(user)
  end

  def search_params
    hash = params.require(:search).permit(:email, :name, :katakana_name)
                 .compact_blank.to_h { |k, v| [k, "%#{v.strip}%"] }
    return {} if hash.empty?

    string = hash.keys.map { |k| "#{k} LIKE :#{k}" }.join(' AND ')
    [string, hash]
  end

  def user_params
    params.require(:user).permit(
      :id, :email, :kana_first, :prefecture, :address, :postcode, :phone,
      :first_name, :family_name, :email_confirmation, :kana_family, :password,
      :password_confirmation
    )
  end
end
