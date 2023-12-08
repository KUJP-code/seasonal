# frozen_string_literal: true

class PriceListsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @price_lists = policy_scope PriceList
  end

  def new
    @price_list = authorize PriceList.new
  end

  def edit
    @price_list = authorize PriceList.find(params[:id])
  end

  def create
    @price_list = authorize PriceList.new(price_list_params)

    if @price_list.save
      redirect_to price_lists_path,
                  notice: t('success', model: 'Price List ', action: 'created')
    else
      render :new, status: :unprocessable_entity, alert: t('.failure')
    end
  end

  def update
    @price_list = authorize PriceList.find(params[:id])

    if @price_list.update(price_list_params)
      redirect_to price_lists_path,
                  notice: t('success', model: 'Price List ', action: 'update')
    else
      render :edit, status: :unprocessable_entity, alert: t('.failure')
    end
  end

  private

  def price_list_params
    params.require(:price_list).permit(
      :id, :name, :course1, :course5, :course10, :course15, :course20,
      :course25, :course30, :course35, :course40, :course45, :course50
    )
  end
end
