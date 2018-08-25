module Api::PropertiesDoc
  extend BaseDoc

  namespace 'api'
  resource :properties

  doc_for :create do
    api :POST, '/properties', 'Create property'
    error 401, 'Unauthorized'
    error 422, "Unable to create entity (e.g. validation failed)"
    error 500, "Server Error"
    param :property, Hash, desc: 'property parameter', required: true do
      param :name, String, desc: 'property name', required: true
      param :street_address, String, desc: 'e.g. 150 Broadway Ave.'
      param :state, String, desc: 'e.g. New York'
      param :zip_code, String, desc: 'e.g. 10003'
      param :city, Integer, desc: 'e.g. Chicago'
    end
    param :user, Hash, desc: 'user parameter - if given, it will create a new user or send an invitation to user if user is found with email', required: false do
      param :name, String, desc: 'user name'
      param :email, String, desc: 'user email'
    end

    description <<-EOS
      If successful, it returns a json with following fields

      Property object contains:
        new_user_created: true if new user was created
        invitation_sent: true if invitation was sent
        message: message
    EOS
  end

end
