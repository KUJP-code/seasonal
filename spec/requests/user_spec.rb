# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'staff for UserPolicy request' do
  it 'can access index' do
    get users_path
    expect(response).to have_http_status(:success)
  end

  it 'can access customer profiles' do
    get user_path(id: record.id)
    expect(response).to have_http_status(:success)
  end

  it 'can access new user form' do
    get new_user_path
    expect(response).to have_http_status(:success)
  end

  it 'can create new user' do
    user_attributes = attributes_for(
      :user,
      first_name: 'Test',
      family_name: 'User',
      kana_first: 'テスト',
      kana_family: 'ユ'
    )
    expect { post users_path, params: { user: user_attributes } }
      .to change(User, :count).by(1)
  end

  it 'can access edit user form' do
    get edit_user_path(id: record.id)
    expect(response).to have_http_status(:success)
  end

  it 'can edit customer profile' do
    user_attributes = attributes_for(
      :user,
      first_name: 'Test',
      family_name: 'User',
      kana_first: 'テスト',
      kana_family: 'ユ'
    )
    patch user_path(id: record.id), params: { user: user_attributes }
    expect(record.reload.name).to eq('User Test')
  end

  it 'can merge children' do
    expect { post merge_children_path(ss_kid: create(:child).id, non_ss_kid: create(:child).id) }
      .to change(Child, :count).by(1)
  end
end

RSpec.shared_examples 'customer for UserPolicy request' do
  it 'cannot view index' do
    get users_path
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'cannot view customer profiles' do
    get user_path(id: record.id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'cannot view new user form' do
    get new_user_path
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'cannot create new user' do
    user_attributes = attributes_for(
      :user,
      first_name: 'Test',
      family_name: 'User',
      kana_first: 'テスト',
      kana_family: 'ユ'
    )
    expect { post users_path, params: { user: user_attributes } }
      .not_to change(User, :count)
  end

  it 'cannot edit customer profile' do
    get edit_user_path(id: record.id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end

  it 'cannot update customer profile' do
    user_attributes = attributes_for(
      :user,
      first_name: 'Test',
      family_name: 'User',
      kana_first: 'テスト',
      kana_family: 'ユ'
    )
    expect { patch user_path(id: record.id), params: { user: user_attributes } }
      .not_to change(record, :name)
  end

  it 'cannot merge children' do
    post merge_children_path(ss_kid: create(:child).id, non_ss_kid: create(:child).id)
    expect(flash[:alert]).to eq(I18n.t('not_authorized'))
  end
end

RSpec.shared_examples 'non-admin staff for UserPolicy request' do
  context 'when viewing admin profile' do
    let(:record) { create(:admin) }

    it 'cannot view admin profiles' do
      get user_path(id: record.id)
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end

  context 'when viewing area manager profile' do
    let(:record) { create(:area_manager) }

    it 'cannot view area manager profiles' do
      get user_path(id: record.id)
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end

  context 'when viewing school manager profile' do
    let(:record) { create(:school_manager) }

    it 'cannot view school manager profiles' do
      get user_path(id: record.id)
      expect(flash[:alert]).to eq(I18n.t('not_authorized'))
    end
  end
end

RSpec.shared_examples 'Nacrissus for UserPolicy request' do
  it 'can view own profile' do
    user.managed_schools << create(:school) if user.school_manager?
    get user_path(id: user.id)
    expect(response).to have_http_status(:ok)
  end
end

RSpec.describe User do
  let(:record) { create(:customer) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    context 'when viewing other admin profile' do
      let(:record) { create(:admin) }

      it 'can view admin profiles' do
        get user_path(id: record.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when viewing area manager profile' do
      let(:record) { create(:area_manager) }

      it 'can view area manager profiles' do
        get user_path(id: record.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when viewing school manager profile' do
      let(:record) { create(:school_manager) }

      before do
        record.managed_schools << create(:school)
      end

      it 'can view school manager profiles' do
        get user_path(id: record.id)
        expect(response).to have_http_status(:ok)
      end
    end

    it_behaves_like 'staff for UserPolicy request'
    it_behaves_like 'Nacrissus for UserPolicy request'
  end

  context 'when area manager' do
    let(:user) { create(:area_manager) }

    it_behaves_like 'non-admin staff for UserPolicy request'
    it_behaves_like 'Nacrissus for UserPolicy request'
    it_behaves_like 'staff for UserPolicy request'
  end

  context 'when school manager' do
    let(:user) { create(:school_manager) }

    it_behaves_like 'non-admin staff for UserPolicy request'
    it_behaves_like 'Nacrissus for UserPolicy request'
    it_behaves_like 'staff for UserPolicy request'
  end

  context 'when statistician' do
    let(:user) { create(:statistician) }

    it_behaves_like 'Nacrissus for UserPolicy request'
    it_behaves_like 'customer for UserPolicy request'
  end

  context 'when customer' do
    let(:user) { create(:customer) }

    it_behaves_like 'Nacrissus for UserPolicy request'
    it_behaves_like 'customer for UserPolicy request'
  end
end
