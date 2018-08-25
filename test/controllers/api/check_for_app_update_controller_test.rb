require 'test_helper'

describe Api::CheckForAppUpdateController, "GET #index" do
  let(:device_platform) { 'ios' }
  let(:current_version) { "2" }
  let(:release1){ create(:mobile_version, platform: device_platform, version: "1.9") }
  let(:release101){ create(:mobile_version, platform: device_platform, version: "1.10.1") }
  let(:release11){ create(:mobile_version, platform: device_platform, version: "1.10") }
  let(:release2){ create(:mobile_version, platform: device_platform, version: current_version) }
  let(:mandatory_release){ create(:mobile_version, platform: device_platform, version: current_version, update_mandatory: true) }
  let(:valid_request) {
    get :index, format: :json, params: { platform: device_platform, version: current_version }
  }

  describe 'with no releases yet in this platform' do
    it 'must not prompt for upgrade' do
      valid_request
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], false
    end
  end

  describe 'with releases in this platform' do
    it 'must not prompt for upgrade if newer version don\'t exists' do
      release1
      release2
      get :index, format: :json, params: { platform: device_platform, version: release2.version }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], false
      assert_equal json['update_mandatory'], false
    end

    it 'must prompt for upgrade a mandatory update if new version exists' do
      release1
      mandatory_release
      get :index, format: :json, params: { platform: device_platform, version: release1.version }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], true
      assert_equal json['update_mandatory'], true
    end

    it 'must prompt for upgrade if new sub minor version exists' do
      release1
      release101
      get :index, format: :json, params: { platform: device_platform, version: release1.version }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], true
      assert_equal json['update_mandatory'], false
    end

    it 'must prompt for upgrade if new minor version exists' do
      release1
      release11
      get :index, format: :json, params: { platform: device_platform, version: release1.version }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], true
      assert_equal json['update_mandatory'], false
    end

    it 'must prompt for upgrade if new major version exists' do
      release1
      release11
      get :index, format: :json, params: { platform: device_platform, version: release1.version }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], true
      assert_equal json['update_mandatory'], false
    end

    it 'must prompt for upgrade if new major version exists even if not created in order' do
      release1
      release11
      release101
      get :index, format: :json, params: { platform: device_platform, version: release1.version }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal json['prompt_for_upgrade'], true
      assert_equal json['update_mandatory'], false
    end
  end

  # describe 'with invalid params' do
  #   let(:invalid_request) {
  #     get :index, format: :json, params: { platform: 'something', version: '123' }
  #   }

  #   it 'must fail' do
  #     invalid_request
  #     assert_response 500
  #   end
  # end
end
