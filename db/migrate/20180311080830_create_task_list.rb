class CreateTaskList < ActiveRecord::Migration[5.0]
  def change
    create_table :task_lists do |t|
      t.belongs_to :property, index: true
      t.string :name
      t.text :description
      t.integer :created_by_id
      t.integer :updated_by_id
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :task_lists, :created_by_id
    add_index :task_lists, :updated_by_id

    create_table :task_list_roles do |t|
      t.belongs_to :property, index: true
      t.belongs_to :task_list, index: true
      t.belongs_to :department, index: true
      t.belongs_to :role, index: true

      t.integer :scope_type, default: 0

      t.timestamps null: false
    end

    create_table :task_items do |t|
      t.belongs_to :property, index: true
      t.belongs_to :task_list, index: true
      t.integer :category_id
      t.string :title
      t.string :image
      t.integer :row_order
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :task_items, :category_id

    create_table :task_list_records do |t|
      t.belongs_to :property, index: true
      t.belongs_to :user, index: true
      t.belongs_to :task_list, index: true

      t.datetime :started_at
      t.datetime :completed_at
      t.integer :completed_by_id
      t.integer :status, default: 0

      t.text :notes
      t.text :reviewer_notes
      t.datetime :review_notified_at

      t.timestamps null: false
    end

    add_index :task_list_records, :completed_by_id

    create_table :task_item_records do |t|
      t.belongs_to :property, index: true
      t.belongs_to :user, index: true
      t.belongs_to :task_list_record, index: true
      t.belongs_to :task_item, index: true

      t.datetime :completed_at
      t.text :comment
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps null: false
    end

    add_index :task_item_records, :created_by_id
    add_index :task_item_records, :updated_by_id
  end
end
