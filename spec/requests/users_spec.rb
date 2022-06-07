require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:ok)
    end

    it 'Signup | Ruby on Rails Tutorial Sample Appが含まれること' do
      get signup_path
      expect(response.body).to include full_title('Sign up')
    end
  end

  context '有効な値の場合' do
    let(:user_params) { { user: { name: 'Example User',
                                  email: 'user@example.com',
                                  password: 'password',
                                  password_confirmation: 'password' } } }

    it '登録されること' do
      expect {
        post users_path, params: user_params
      }.to change(User, :count).by 1
    end

    # it 'users/showにリダイレクトされること' do
    #   post users_path, params: user_params
    #   user = User.last
    #   expect(response).to redirect_to user
    # end

    it 'flashが表示されること' do
      post users_path, params: user_params
      expect(flash).to be_any
    end
  end

  describe 'POST /users #create' do
    it '無効な値だと登録されないこと' do
      expect {
        post users_path, params: { user: { name: '',
                                           email: 'user@invlid',
                                           password: 'foo',
                                           password_confirmation: 'bar' } }
      }.to_not change(User, :count)
    end
  end
end
