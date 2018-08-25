Lodgistics::Application.routes.draw do
  apipie
  require 'sidekiq/web'

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  authenticate :admin do
    mount Blazer::Engine, at: "admin/intelligence"
  end

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    # registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }, skip: [:registrations]

  %w( 403 404 500 ).each do |code|
    get code, to: "errors#show", code: code
  end

  namespace :api do
    resource :auth, only: [:create, :destroy], controller: :auth
    resource :profile, only: [:show, :update], controller: :profile
    resources :task_lists, only: [:index, :show, :destroy] do
      collection do
        get :activities
        get :all
      end
      member do
        post :start_resume
      end
    end
    resources :task_list_records, only: [:show] do
      member do
        post :finish
        post :review
      end
    end
    resources :task_item_records, only: [] do
      member do
        post :complete
        post :reset
      end
    end
    resources :task_items, only: [:create, :update, :destroy]
    resources :locations, only: [:index]
    resources :roles, only: [:index]
    resources :properties, only: [:create, :index]
    resources :in_app_notifications, only: [:index]
    resources :departments, only: [:index]
    resources :public_areas, only: [:index, :show] do
      resources :checklist_items, only: [ :index ]
      collection do
        get :checklist_items
      end
    end
    resources :rooms, only: [] do
      collection do
        get :checklist_items
      end
    end
    resources :acknowledgements, only: [:index, :create, :show] do
      collection do
        get :sent
        get :received
      end
    end
    resources :feeds, only: [:index, :create, :show, :update] do
      resources :work_orders, only: [ :create ]
      collection do
        get :broadcasts
        get :follow_ups
      end
    end
    get '/broadcasts' => 'feeds#broadcasts'
    resources :chats, only: [:create, :update, :index] do
      collection do
        get :group_only
        get :private_only
      end
      member do
        get :messages
      end
    end
    resources :chat_messages, only: [ :index, :create, :show ] do
      resources :work_orders, only: [ :create ]
      collection do
        get :updates
        put :mark_read_mass
      end
      member do
        put :mark_read
      end
    end
    resources :users, only: [:index, :show, :update, :create] do
      member do
        get :roles_and_departments
        put :confirm
      end
      collection do
        post :invite
        post :multi_invite
        get :request_confirm
      end
    end
    resources :mentions, only: [:index, :update] do
      collection do
        put :snooze
        put :unsnooze
        put :clear
      end
    end
    resources :work_orders, only: [:index, :create, :show, :update] do
      member do
        put :close
      end

      collection do
        get :assignable_users
      end
    end
    resources :checklist_items, only: [:index]
    resources :chat_mentions, only: [:update]
    resource :passwords, only: [:create, :update]
    resources :permissions, only: [:index]
    resources :push_notification_settings, only: [:index]
    resource :push_notification_settings, only: [:update]
    get '/s3_sign', to: 'auth#s3_sign'
    resources :check_for_app_update, only: [:index]
  end
  get '/login/:auth_token' => 'login#create'
  get '/how-to-videos' => 'videos#how_to_videos'

  resources :chats, only: [:show, :index, :new, :create]
  resources :messages, controller: :chats, only: [ :show, :index, :new, :create ]
  resources :chat_messages, only: [:create]
  resources :task_lists, only: [:index, :show, :new, :edit, :create, :update] do
    collection do
      get :activities
      get :setup
    end
  end

  namespace :corporate do
    root to: 'pages#dashboard'
    resources :settings, only: [:index]
    resources :property_connections, only: [:show, :update]
    resources :purchase_requests, only: [:edit, :update], path: 'requests'
    get '/spend_budget_by_hotel_data' => 'pages#spend_budget_by_hotel', as: 'spend_budget_by_hotel_data'
    get '/work_order_clouds' => 'pages#work_order_clouds', as: 'work_order_clouds'
    get '/open_work_order_by_hotel' => 'pages#open_work_orders_by_hotel', as: 'open_work_orders_by_hotel'
  end

  namespace :maintenance do
    root to: 'pages#dashboard' # probably need to move it under /dashboard, @HUGO
    get :setup, to: 'setup#index', as: :setup
    get '/setup/rooms', to: 'setup#rooms', as: :setup_rooms
    get '/setup/public_areas', to: 'setup#public_areas', as: :setup_public_areas
    get '/setup/equipment', to: 'setup#equipment', as: :setup_equipment
    resources :rooms, only: [:show, :index, :create, :update] do
      get :inspection, on: :collection
      get :inspect, on: :member
    end
    resources :checklist_items, only: [:index, :create, :update,:destroy]
    resources :cycles, only: [:create] do
      post :create_next, on: :collection
    end
    resources :checklist_item_maintenances, only: [:index, :create, :destroy] do
      member do
        post :inspect
        delete :cancel_inspect
      end

      collection do
        get :equipment
      end
    end
    resources :public_areas, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :checklist_items
        get :inspection
      end
      get :inspect, on: :member
    end
    resources :records, only: [:index, :update, :show, :destroy] do
      member do
        post :complete_inspection
        post :cancel_inspection
      end
    end
    resources :work_orders do
      get :export, on: :collection
    end
    resources :materials, only: [:index, :create, :update, :destroy]
    resources :equipment_types, only: [:index, :create, :update, :destroy] do
      resources :equipment_checklist_items, only: [:index, :create, :show, :update, :destroy]
    end
    resources :equipments, only: [:index, :show, :create, :update, :destroy]

    get '/week_vs_completed_rooms_data' => 'pages#week_vs_completed_rooms_data', as: 'week_vs_completed_rooms_data'
    get '/pm_room_progress_data' => 'pages#pm_room_progress_data', as: 'pm_room_progress_data'
  end

  namespace :admin do
    root to: 'pages#dashboard'
    resources :users, only: [:edit, :update]
    resources :customers, only: [:index, :new, :create, :show] do
      member do
        post :impersonate
      end
    end
  end

  devise_for :admins, path: 'admin', controllers: {
                        sessions: 'admin/sessions',
                        passwords: 'admin/passwords'
                      }

  resource :corporate_connections

  get :spend_vs_budgets_data, to: 'pages#spend_vs_budgets_data'
  get :s3_sign, to: 'pages#s3_sign'

  authenticated :user do
    root 'pages#home', as: :authenticated_root
  end

  authenticated :admin do
    root 'pages#dashboard', as: :admin_authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root 'users/sessions#new', as: :unauthenticated_root
    end
    namespace :users, as: :user do
      put "/confirm" => "confirmations#confirm", as: :confirm
      put '/switch_current_property', to: 'sessions#switch_current_property', as: :switch_current_property
      resource :registration, only: [:edit, :update]
    end
  end
  resources :property_settings, path: 'settings', only: [:index]
  resources :categories, :locations, :lists do
    get 'rearrange', on: :member
    get 'destroy', on: :collection, as: 'destroy'
  end
  resources :items do
    collection do
      get 'start_order'
      get 'edit_multiple_tags'
      put 'update_multiple_tags'
      get :new_import
      post :import
      get 'destroy', as: 'destroy'
    end
  end
  resources :permissions, only: [:index] do
    collection do
      post 'update_all'
    end
  end
  resources :properties, only: [:show, :index, :update]
  resources :tags do
    get 'rearrange', on: :member
  end
  resources :purchase_orders, except: [:edit, :new, :create], path: 'orders' do
    member do
      post :send_fax, to: 'fax#create'
      get :fax_status, to: 'fax#show'
      post :update_fax, to: 'fax#update'
      post :send_email, to: 'email#create'
      post :send_vpt, to: 'vpt#create'
      get :print
    end
  end
  resources :purchase_receipts, only: [:new, :create], path: 'receipts'
  resources :purchase_requests, path: 'requests' do
    member do
      get :inventory_print
    end
  end
  resources :users do
    member do
      get :change_password
    end

    collection do
      post :valid_username
      post :confirm_username
    end
  end
  resources :work_order_messages, controller: :messages
  resources :budgets
  resources :schedules, only: [:create, :update, :destroy]
  resources :occurrences, only: [:create]

  resources :reports do
    member do
      put :favorite
    end
    collection do
      get :favorites
      #get *Report.pluck(:permalink).map{|p| p + '_data'} if Report.any?
      get :trending_cloud
      scope :render do
        get :vendor_spend
        get :category_spend
        get :items_consumption
        get :item_orders_chart_data
        get :items_spend
        get :item_price_variance
        get :inventory_vs_ordering
        get :maintenance_work_orders
        get :pm_productivity_report
        get :maintenance_pm_productivity_data
        get :room_pm_progress_data
        get :work_order_productivity_data
        get :guest_room_pm_analysis
        get :public_area_pm_analysis
        get :equipment_pm_analysis
        get :work_order_trendings
      end
    end
  end


  resources :vendors
  resources :room_types
  resources :departments
  resources :notifications
  resources :activities, only: [:index]
  resources :join_invitations do
    get 'accept', on: :member
  end
  # resources :guest_logs do
  #   get 'like', on: :member
  #   post 'set_alarm', on: :collection
  #   get 'check_alarm', on: :member
  #   delete 'remove_alarm', on: :member
  # end

  namespace :engage do
    get :dashboard, to: 'dashboard#index', as: :dashboard
    resources :messages, only: [:index, :create, :update]
    resources :entities, only: [:index, :create, :update, :destroy]
  end

  post 'punchout/:property_id/:vendor_id/shopping_cart', to: "punchout#shopping_cart", as: 'punchout_shopping_cart'
  get 'punchout/:property_id/:vendor_id', to: "punchout#create", as: 'start_punchout'

  get 'analytics', to: "analytics#index"
  get 'forecasts/(week/:year/:month/:day)', to: "forecasts#index", as: "forecasts"
  put 'forecast', to: "forecasts#update", as: "update_forecast"

  get '/fax', to: 'fax#show'
  post '/fax', to: 'fax#create'
  post '/phaxio', to: 'fax#update'
  get 'dashboard', to: 'pages#dashboard', :as => :dashboard
  get 'pages/home'
  # authenticated :user do
  #   root to: 'pages#dashboard'
  # end

  resource :translation, controller: :translation, only: [:create]

  #root to: 'users/sessions#new'
  if Rails.env.development? or Rails.env.qa?
    mount MailerPreview => 'mailer_view'
    mount Sidekiq::Web, at: '/sidekiq'
  end

end
