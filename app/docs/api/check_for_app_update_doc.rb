module Api::CheckForAppUpdateDoc
  extend BaseDoc

  namespace 'api'
  resource :check_for_app_update

  doc_for :index do
    api :GET, '/check_for_app_update', '[PUBLIC] Check for updates of the mobile app'
    param :platform, MobileVersion.platforms.keys, required: true
    param :version, String, required: true
    description <<-EOS
      If successful, it returns a json with following data, with status <tt>200</tt>
      Response Object:
        prompt_for_upgrade: if should update to new version
        update_mandatory: if newer version was flagged as mandatory update
        message: descriptive text
    EOS
    example <<-EOS
    GET /apí/check_for_app_update.json
    {
      "prompt_for_upgrade": true,
      "update_mandatory": false,
      "message": "There is a new version available"
    }

    GET /apí/check_for_app_update.json
    {
      "prompt_for_upgrade": false,
      "update_mandatory": false,
      "message": "There are no mobile apps"
    }

    GET /apí/check_for_app_update.json
    {
      "prompt_for_upgrade": false,
      "update_mandatory": false,
      "message": "You have installed latest version"
    }

    EOS
  end


end
