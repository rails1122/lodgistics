require 'minitest/autorun'
require 'test_helper'

describe Maintenance::WorkOrdersController, "GET #index" do
  include Devise::Test::ControllerHelpers

  describe "when not logged in" do
    it do
      get :index
      assert_response 302
    end
  end

  describe "after a user logs in" do
    let(:user) { create(:user) }

    before do
      sign_in user
      # create some work orders
    end

    #it do
    #  get :index
    #  assert_response 200
    #end
  end

  describe "after a user with permission X logs in" do
    let(:user_with_permission_X) { create(:user) }

    before do
      sign_in user_with_permission_X
      # create some work orders
    end

    #it do
    #  get :index
    #  assert_response 200
    #end
  end
end
