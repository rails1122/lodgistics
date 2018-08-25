# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180714100405) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "acknowledgements", force: :cascade do |t|
    t.string   "acknowledeable_type"
    t.integer  "acknowledeable_id"
    t.integer  "user_id"
    t.datetime "checked_at"
    t.integer  "target_user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["acknowledeable_type", "acknowledeable_id"], name: "index_on_acknowledeable", using: :btree
    t.index ["user_id"], name: "index_acknowledgements_on_user_id", using: :btree
  end

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id"
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admins_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  end

  create_table "alarms", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "user_id"
    t.datetime "alarm_at"
    t.text     "body"
    t.integer  "checked_by"
    t.datetime "checked_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 255,                null: false
    t.boolean  "active",                   default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_api_keys_on_user_id", using: :btree
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "query_id"
    t.text     "statement"
    t.string   "data_source", limit: 255
    t.datetime "created_at"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "query_id"
    t.string   "state",       limit: 255
    t.string   "schedule",    limit: 255
    t.text     "emails"
    t.string   "check_type",  limit: 255
    t.text     "message"
    t.datetime "last_run_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.integer  "dashboard_id"
    t.integer  "query_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.integer  "creator_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.integer  "creator_id"
    t.string   "name",        limit: 255
    t.text     "description"
    t.text     "statement"
    t.string   "data_source", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "budgets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.decimal  "amount"
    t.integer  "month"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_message_reads", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["message_id"], name: "index_chat_message_reads_on_message_id", using: :btree
    t.index ["user_id", "message_id"], name: "index_chat_message_reads_on_user_id_and_message_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_chat_message_reads_on_user_id", using: :btree
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.text     "encrypted_message"
    t.datetime "deleted_at"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reads_count",                   default: 0
    t.integer  "chat_id"
    t.integer  "responding_to_chat_message_id"
    t.integer  "work_order_id"
    t.string   "room_number"
    t.string   "image"
    t.index ["chat_id"], name: "index_chat_messages_on_chat_id", using: :btree
    t.index ["property_id"], name: "index_chat_messages_on_property_id", using: :btree
    t.index ["sender_id"], name: "index_chat_messages_on_sender_id", using: :btree
  end

  create_table "chat_user_roles", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "department_id"
    t.integer  "role_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["department_id"], name: "index_chat_user_roles_on_department_id", using: :btree
    t.index ["group_id"], name: "index_chat_user_roles_on_group_id", using: :btree
    t.index ["property_id"], name: "index_chat_user_roles_on_property_id", using: :btree
    t.index ["role_id"], name: "index_chat_user_roles_on_role_id", using: :btree
  end

  create_table "chat_users", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "index_chat_users_on_group_id", using: :btree
    t.index ["user_id"], name: "index_chat_users_on_user_id", using: :btree
  end

  create_table "chats", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "property_id"
    t.integer  "created_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_message_at"
    t.integer  "user_id"
    t.boolean  "is_private",                  default: false
    t.string   "image"
    t.index ["created_by_id"], name: "index_chats_on_created_by_id", using: :btree
    t.index ["is_private"], name: "index_chats_on_is_private", using: :btree
    t.index ["last_message_at"], name: "index_chats_on_last_message_at", using: :btree
    t.index ["property_id"], name: "index_chats_on_property_id", using: :btree
    t.index ["user_id"], name: "index_chats_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 255
    t.string   "title",            limit: 255
    t.text     "encrypted_body"
    t.string   "subject",          limit: 255
    t.integer  "user_id",                      null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "conversions", force: :cascade do |t|
    t.integer  "unit_id"
    t.float    "factor"
    t.integer  "other_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "corporate_connections", force: :cascade do |t|
    t.integer  "corporate_id"
    t.integer  "property_id"
    t.string   "email",         limit: 255
    t.string   "state",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
  end

  create_table "corporates", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "departments_tags", force: :cascade do |t|
    t.integer "category_id"
    t.integer "department_id"
  end

  create_table "departments_users", force: :cascade do |t|
    t.integer "department_id"
    t.integer "user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string   "token",      limit: 255,                null: false
    t.string   "platform",   limit: 255,                null: false
    t.boolean  "enabled",                default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_devices_on_user_id", using: :btree
  end

  create_table "engage_entities", force: :cascade do |t|
    t.integer  "property_id"
    t.text     "body"
    t.string   "room_number",     limit: 255
    t.string   "entity_type",     limit: 255
    t.integer  "created_by_id"
    t.integer  "completed_by_id"
    t.datetime "completed_at"
    t.datetime "due_date"
    t.string   "status",          limit: 255
    t.hstore   "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "engage_messages", force: :cascade do |t|
    t.integer  "property_id"
    t.string   "title",           limit: 255
    t.text     "encrypted_body"
    t.string   "room_number",     limit: 255
    t.integer  "created_by_id"
    t.date     "broadcast_start"
    t.date     "broadcast_end"
    t.integer  "work_order_id"
    t.datetime "completed_at"
    t.integer  "completed_by_id"
    t.date     "follow_up_start"
    t.date     "follow_up_end"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "image_height"
    t.integer  "image_width"
    t.string   "image"
    t.index ["property_id"], name: "index_engage_messages_on_property_id", using: :btree
    t.index ["updated_at"], name: "index_engage_messages_on_updated_at", using: :btree
  end

  create_table "in_app_notifications", force: :cascade do |t|
    t.integer  "recipient_user_id"
    t.datetime "read_at"
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.integer  "property_id"
    t.integer  "notification_type", default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.jsonb    "data"
    t.index ["notifiable_type", "notifiable_id"], name: "index_in_app_notifications_on_notifiable_type_and_notifiable_id", using: :btree
  end

  create_table "item_orders", force: :cascade do |t|
    t.integer  "purchase_order_id"
    t.integer  "item_id"
    t.integer  "item_request_id"
    t.decimal  "quantity"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id"], name: "index_item_orders_on_item_id", using: :btree
    t.index ["item_request_id"], name: "index_item_orders_on_item_request_id", using: :btree
    t.index ["purchase_order_id"], name: "index_item_orders_on_purchase_order_id", using: :btree
  end

  create_table "item_receipts", force: :cascade do |t|
    t.integer  "purchase_receipt_id"
    t.integer  "item_order_id"
    t.integer  "item_id"
    t.decimal  "quantity"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id"], name: "index_item_receipts_on_item_id", using: :btree
    t.index ["purchase_receipt_id"], name: "index_item_receipts_on_purchase_receipt_id", using: :btree
  end

  create_table "item_requests", force: :cascade do |t|
    t.integer  "purchase_request_id"
    t.integer  "item_id"
    t.decimal  "quantity"
    t.decimal  "count"
    t.decimal  "part_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "skip_inventory"
    t.decimal  "prev_quantity"
    t.index ["item_id"], name: "index_item_requests_on_item_id", using: :btree
    t.index ["purchase_request_id"], name: "index_item_requests_on_purchase_request_id", using: :btree
  end

  create_table "item_tags", force: :cascade do |t|
    t.integer "item_id"
    t.integer "tag_id"
    t.string  "tag_type", limit: 255
    t.index ["item_id", "tag_id"], name: "index_item_tags_on_item_id_and_tag_id", using: :btree
    t.index ["tag_id", "item_id"], name: "index_item_tags_on_tag_id_and_item_id", using: :btree
  end

  create_table "item_transactions", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "type",               limit: 255
    t.decimal  "change"
    t.string   "purchase_step_type", limit: 255
    t.integer  "purchase_step_id"
    t.decimal  "cumulative_total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item_id"], name: "index_item_transactions_on_item_id", using: :btree
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.decimal  "count"
    t.integer  "frequency"
    t.decimal  "par_level"
    t.string   "image_file_name",         limit: 255
    t.string   "image_content_type",      limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "item_transactions_count",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.integer  "subpack_unit_id"
    t.integer  "pack_unit_id"
    t.float    "unit_subpack"
    t.float    "subpack_size"
    t.integer  "inventory_unit_id"
    t.integer  "price_unit_id"
    t.integer  "property_id"
    t.boolean  "is_taxable"
    t.boolean  "archived",                            default: false
    t.text     "description"
    t.boolean  "is_asset"
    t.decimal  "purchase_cost"
    t.decimal  "pack_size"
    t.integer  "brand_id"
    t.integer  "number"
    t.index ["inventory_unit_id"], name: "index_items_on_inventory_unit_id", using: :btree
    t.index ["pack_unit_id"], name: "index_items_on_pack_unit_id", using: :btree
    t.index ["price_unit_id"], name: "index_items_on_price_unit_id", using: :btree
    t.index ["subpack_unit_id"], name: "index_items_on_subpack_unit_id", using: :btree
    t.index ["unit_id"], name: "index_items_on_unit_id", using: :btree
  end

  create_table "join_invitations", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "invitee_id"
    t.text    "params"
    t.integer "targetable_id"
    t.string  "targetable_type", limit: 255
    t.index ["invitee_id"], name: "index_join_invitations_on_invitee_id", using: :btree
    t.index ["sender_id"], name: "index_join_invitations_on_sender_id", using: :btree
  end

  create_table "magic_tags", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.text     "text"
    t.integer  "property_id"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintenance_attachments", force: :cascade do |t|
    t.string   "file",                limit: 255
    t.string   "attachmentable_type", limit: 255
    t.integer  "attachmentable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintenance_checklist_item_maintenances", force: :cascade do |t|
    t.integer  "maintenance_record_id"
    t.integer  "maintenance_checklist_item_id"
    t.string   "status",                        limit: 255
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintenance_checklist_items", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "user_id"
    t.string   "name",             limit: 255
    t.string   "maintenance_type", limit: 255
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_order"
    t.boolean  "is_deleted",                   default: false
    t.integer  "public_area_id"
    t.index ["property_id"], name: "index_maintenance_checklist_items_on_property_id", using: :btree
    t.index ["user_id"], name: "index_maintenance_checklist_items_on_user_id", using: :btree
  end

  create_table "maintenance_cycles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "property_id"
    t.integer  "year"
    t.integer  "start_month"
    t.integer  "frequency_months"
    t.string   "cycle_type",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordinality_number"
    t.index ["property_id"], name: "index_maintenance_cycles_on_property_id", using: :btree
    t.index ["user_id"], name: "index_maintenance_cycles_on_user_id", using: :btree
  end

  create_table "maintenance_equipment", force: :cascade do |t|
    t.string   "make",              limit: 255
    t.string   "name",              limit: 255
    t.string   "location",          limit: 255
    t.date     "buy_date"
    t.date     "replacement_date"
    t.integer  "property_id"
    t.integer  "equipment_type_id"
    t.text     "instruction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "warranty"
    t.integer  "lifespan"
    t.integer  "row_order"
    t.datetime "deleted_at"
  end

  create_table "maintenance_equipment_checklist_items", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "tools_required"
    t.integer  "equipment_type_id"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_order"
    t.integer  "user_id"
    t.integer  "property_id"
    t.integer  "group_id"
  end

  create_table "maintenance_equipment_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "property_id"
    t.integer  "user_id"
    t.text     "instruction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_order"
    t.datetime "deleted_at"
  end

  create_table "maintenance_inspection_details", force: :cascade do |t|
    t.integer  "work_order_id"
    t.integer  "checklist_item_maintenance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintenance_materials", force: :cascade do |t|
    t.integer  "work_order_id"
    t.integer  "item_id"
    t.decimal  "quantity"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maintenance_public_areas", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "property_id"
    t.integer  "user_id"
    t.boolean  "is_deleted",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_order"
  end

  create_table "maintenance_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cycle_id"
    t.string   "maintainable_type",            limit: 255
    t.integer  "maintainable_id"
    t.string   "status",                       limit: 255
    t.text     "notes"
    t.datetime "started_at"
    t.datetime "completed_on"
    t.datetime "inspected_on"
    t.integer  "inspected_by_id"
    t.text     "inspected_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "completed_by_id"
    t.integer  "property_id"
    t.integer  "equipment_checklist_group_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.index ["cycle_id"], name: "index_maintenance_records_on_cycle_id", using: :btree
    t.index ["user_id"], name: "index_maintenance_records_on_user_id", using: :btree
  end

  create_table "maintenance_rooms", force: :cascade do |t|
    t.string   "room_number", limit: 255
    t.integer  "property_id"
    t.integer  "floor"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_maintenance_rooms_on_user_id", using: :btree
  end

  create_table "maintenance_work_orders", force: :cascade do |t|
    t.integer  "maintainable_id"
    t.string   "maintainable_type",             limit: 255
    t.integer  "checklist_item_maintenance_id"
    t.integer  "opened_by_user_id"
    t.datetime "opened_at"
    t.string   "status",                        limit: 255
    t.integer  "closed_by_user_id"
    t.datetime "closed_at"
    t.text     "closing_comment",                           default: ""
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "property_id"
    t.string   "other_maintainable_location",   limit: 255
    t.string   "priority",                      limit: 1,   default: "m"
    t.integer  "assigned_to_id"
    t.date     "due_to_date"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.integer  "duration"
    t.datetime "deleted_at"
    t.boolean  "recurring",                                 default: false
    t.text     "first_img_url",                             default: ""
    t.text     "second_img_url",                            default: ""
    t.string   "location_name"
    t.index ["property_id"], name: "index_maintenance_work_orders_on_property_id", using: :btree
  end

  create_table "mentions", force: :cascade do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",           default: 0
    t.integer  "mentionable_id"
    t.string   "mentionable_type"
    t.integer  "property_id"
    t.datetime "snoozed_at"
    t.index ["mentionable_type", "mentionable_id"], name: "index_mentions_on_mentionable_type_and_mentionable_id", using: :btree
    t.index ["message_id"], name: "index_mentions_on_message_id", using: :btree
    t.index ["property_id"], name: "index_mentions_on_property_id", using: :btree
    t.index ["status"], name: "index_mentions_on_status", using: :btree
    t.index ["user_id"], name: "index_mentions_on_user_id", using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "messagable_id"
    t.text     "body"
    t.string   "attachment",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "messagable_type", limit: 255
  end

  create_table "mobile_versions", force: :cascade do |t|
    t.integer  "platform"
    t.string   "version"
    t.boolean  "update_mandatory", default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["platform", "version"], name: "index_mobile_versions_on_platform_and_version", unique: true, using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "property_id"
    t.string   "ntype",       limit: 255
    t.integer  "model_id"
    t.string   "message",     limit: 255
    t.boolean  "read",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "occurrences", force: :cascade do |t|
    t.integer  "eventable_id"
    t.string   "eventable_type", limit: 255
    t.integer  "schedule_id"
    t.date     "date"
    t.string   "status",         limit: 255
    t.hstore   "option"
    t.integer  "index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["schedule_id"], name: "index_occurrences_on_schedule_id", using: :btree
  end

  create_table "old_roles", force: :cascade do |t|
    t.integer  "property_id"
    t.string   "name",        limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["property_id"], name: "index_old_roles_on_property_id", using: :btree
  end

  create_table "old_roles_users", id: false, force: :cascade do |t|
    t.integer "old_role_id"
    t.integer "user_id"
    t.index ["old_role_id", "user_id"], name: "index_old_roles_users_on_old_role_id_and_user_id", using: :btree
    t.index ["user_id", "old_role_id"], name: "index_old_roles_users_on_user_id_and_old_role_id", using: :btree
  end

  create_table "permission_attributes", force: :cascade do |t|
    t.integer  "parent_id"
    t.string   "subject",    limit: 255
    t.string   "action",     limit: 255
    t.string   "name",       limit: 255
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
    t.integer  "property_id"
    t.integer  "permission_attribute_id"
    t.text     "options"
    t.index ["role_id"], name: "index_permissions_on_role_id", using: :btree
  end

  create_table "procurement_interfaces", force: :cascade do |t|
    t.string  "interface_type", limit: 255
    t.text    "data"
    t.integer "vendor_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name",   limit: 255
    t.string   "street_address", limit: 255
    t.string   "zip_code",       limit: 255
    t.string   "city",           limit: 255
    t.string   "email",          limit: 255
    t.string   "phone",          limit: 255
    t.string   "fax",            limit: 255
    t.text     "settings"
    t.string   "time_zone",      limit: 255, default: "Eastern Time (US & Canada)"
    t.string   "token",          limit: 6
    t.string   "state"
    t.index ["token"], name: "index_properties_on_token", unique: true, using: :btree
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "purchase_request_id"
    t.integer  "vendor_id"
    t.datetime "sent_at"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fax_id"
    t.string   "fax_last_status",     limit: 255
    t.string   "fax_last_message",    limit: 255
    t.string   "state",               limit: 255
    t.integer  "property_id"
    t.integer  "last_user_id"
    t.index ["purchase_request_id"], name: "index_purchase_orders_on_purchase_request_id", using: :btree
    t.index ["updated_at"], name: "index_purchase_orders_on_updated_at", using: :btree
    t.index ["user_id"], name: "index_purchase_orders_on_user_id", using: :btree
    t.index ["vendor_id"], name: "index_purchase_orders_on_vendor_id", using: :btree
  end

  create_table "purchase_receipts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "purchase_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "freight_shipping"
    t.decimal  "cached_total"
    t.integer  "property_id"
    t.index ["user_id"], name: "index_purchase_receipts_on_user_id", using: :btree
  end

  create_table "purchase_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",            limit: 255
    t.integer  "property_id"
    t.datetime "approved_at"
    t.text     "rejection_reason"
    t.index ["updated_at"], name: "index_purchase_requests_on_updated_at", using: :btree
    t.index ["user_id"], name: "index_purchase_requests_on_user_id", using: :btree
  end

  create_table "push_notification_settings", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "enabled",                                   default: true
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.boolean  "chat_message_notification_enabled",         default: true
    t.boolean  "feed_post_notification_enabled",            default: true
    t.boolean  "acknowledged_notification_enabled",         default: true
    t.boolean  "work_order_completed_notification_enabled", default: true
    t.boolean  "work_order_assigned_notification_enabled",  default: true
    t.boolean  "unread_mention_notification_enabled",       default: true
    t.boolean  "unread_message_notification_enabled",       default: true
    t.datetime "mentions_snoozed_at"
    t.boolean  "feed_broadcast_notification_enabled",       default: true
    t.boolean  "all_new_messages",                          default: true
    t.boolean  "all_new_log_posts",                         default: true
    t.index ["user_id"], name: "index_push_notification_settings_on_user_id", using: :btree
  end

  create_table "report_favoritings", force: :cascade do |t|
    t.integer  "report_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_runs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["property_id"], name: "index_report_runs_on_property_id", using: :btree
    t.index ["report_id"], name: "index_report_runs_on_report_id", using: :btree
    t.index ["user_id"], name: "index_report_runs_on_user_id", using: :btree
  end

  create_table "reports", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "groups",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink",   limit: 255
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "room_occupancies", force: :cascade do |t|
    t.integer  "actual"
    t.integer  "forecast"
    t.integer  "room_type_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["room_type_id"], name: "index_room_occupancies_on_room_type_id", using: :btree
  end

  create_table "room_types", force: :cascade do |t|
    t.integer  "average_occupancy"
    t.integer  "max_occupancy"
    t.integer  "min_occupancy"
    t.string   "name",              limit: 255
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["property_id"], name: "index_room_types_on_property_id", using: :btree
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree
  end

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                        default: "default"
    t.text     "alert"
    t.text     "data"
    t.integer  "expiry",                       default: 86400
    t.boolean  "delivered",                    default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                       default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",                default: false
    t.string   "type",                                             null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",             default: false,     null: false
    t.text     "registration_ids"
    t.integer  "app_id",                                           null: false
    t.integer  "retries",                      default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                   default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
    t.boolean  "content_available",            default: false
    t.text     "notification"
    t.index ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.string   "eventable_type", limit: 255
    t.integer  "eventable_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "recurring_type", limit: 255
    t.integer  "interval"
    t.integer  "days",                       default: [], array: true
    t.integer  "property_id"
    t.time     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id"], name: "index_tag_hierarchies_on_ancestor_id_and_descendant_id", unique: true, using: :btree
    t.index ["descendant_id"], name: "index_tag_hierarchies_on_descendant_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string   "type",              limit: 255
    t.string   "name",              limit: 255
    t.boolean  "unboxed_countable"
    t.integer  "parent_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "property_id"
    t.integer  "user_id"
    t.index ["property_id"], name: "index_tags_on_property_id", using: :btree
  end

  create_table "task_item_records", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "user_id"
    t.integer  "task_list_record_id"
    t.integer  "task_item_id"
    t.datetime "completed_at"
    t.text     "comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["created_by_id"], name: "index_task_item_records_on_created_by_id", using: :btree
    t.index ["property_id"], name: "index_task_item_records_on_property_id", using: :btree
    t.index ["task_item_id"], name: "index_task_item_records_on_task_item_id", using: :btree
    t.index ["task_list_record_id"], name: "index_task_item_records_on_task_list_record_id", using: :btree
    t.index ["updated_by_id"], name: "index_task_item_records_on_updated_by_id", using: :btree
    t.index ["user_id"], name: "index_task_item_records_on_user_id", using: :btree
  end

  create_table "task_items", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "task_list_id"
    t.integer  "category_id"
    t.string   "title"
    t.string   "image"
    t.integer  "row_order"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["category_id"], name: "index_task_items_on_category_id", using: :btree
    t.index ["property_id"], name: "index_task_items_on_property_id", using: :btree
    t.index ["task_list_id"], name: "index_task_items_on_task_list_id", using: :btree
  end

  create_table "task_list_records", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "user_id"
    t.integer  "task_list_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "finished_by_id"
    t.integer  "status",             default: 0
    t.text     "notes"
    t.text     "reviewer_notes"
    t.datetime "review_notified_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "reviewed_at"
    t.integer  "reviewed_by_id"
    t.index ["finished_by_id"], name: "index_task_list_records_on_finished_by_id", using: :btree
    t.index ["property_id"], name: "index_task_list_records_on_property_id", using: :btree
    t.index ["reviewed_by_id"], name: "index_task_list_records_on_reviewed_by_id", using: :btree
    t.index ["task_list_id"], name: "index_task_list_records_on_task_list_id", using: :btree
    t.index ["user_id"], name: "index_task_list_records_on_user_id", using: :btree
  end

  create_table "task_list_roles", force: :cascade do |t|
    t.integer  "property_id"
    t.integer  "task_list_id"
    t.integer  "department_id"
    t.integer  "role_id"
    t.integer  "scope_type",    default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["department_id"], name: "index_task_list_roles_on_department_id", using: :btree
    t.index ["property_id"], name: "index_task_list_roles_on_property_id", using: :btree
    t.index ["role_id"], name: "index_task_list_roles_on_role_id", using: :btree
    t.index ["task_list_id"], name: "index_task_list_roles_on_task_list_id", using: :btree
  end

  create_table "task_lists", force: :cascade do |t|
    t.integer  "property_id"
    t.string   "name"
    t.text     "description"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "inactivated_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.text     "notes"
    t.integer  "inactivated_by_id"
    t.index ["created_by_id"], name: "index_task_lists_on_created_by_id", using: :btree
    t.index ["inactivated_by_id"], name: "index_task_lists_on_inactivated_by_id", using: :btree
    t.index ["property_id"], name: "index_task_lists_on_property_id", using: :btree
    t.index ["updated_by_id"], name: "index_task_lists_on_updated_by_id", using: :btree
  end

  create_table "units", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_list_usages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "property_id"
    t.string   "title",                limit: 255
    t.decimal  "order_approval_limit",             default: "0.0"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_user_roles_on_deleted_at", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.datetime "deleted_at"
    t.string   "email",                  limit: 255, default: ""
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "authentication_token",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_user_id"
    t.string   "avatar",                 limit: 255
    t.decimal  "order_approval_limit",               default: "0.0"
    t.integer  "corporate_id"
    t.string   "phone_number",           limit: 255
    t.text     "settings"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "username",               limit: 255
    t.boolean  "is_system_user",                     default: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "vendor_items", force: :cascade do |t|
    t.boolean  "preferred"
    t.decimal  "items_per_box"
    t.integer  "vendor_id"
    t.integer  "item_id"
    t.integer  "box_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price_cents",                default: 0,     null: false
    t.string   "price_currency", limit: 255, default: "USD", null: false
    t.string   "sku",            limit: 255
    t.index ["box_unit_id"], name: "index_vendor_items_on_box_unit_id", using: :btree
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "street_address",  limit: 255
    t.string   "zip_code",        limit: 255
    t.string   "city",            limit: 255
    t.string   "email",           limit: 255
    t.string   "phone",           limit: 255
    t.string   "fax",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name",    limit: 255
    t.string   "shipping_method", limit: 255
    t.string   "shipping_terms",  limit: 255
    t.integer  "property_id"
    t.string   "payload_id",      limit: 255
    t.index ["name"], name: "index_vendors_on_name", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type", limit: 255
    t.integer  "voter_id"
    t.string   "voter_type",   limit: 255
    t.boolean  "vote_flag"
    t.string   "vote_scope",   limit: 255
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  end

  add_foreign_key "acknowledgements", "users"
  add_foreign_key "push_notification_settings", "users"
end
