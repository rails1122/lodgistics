module Api::TaskItemRecordsDoc
  extend BaseDoc

  namespace 'api'
  resource :task_item_records

  doc_for :complete do
    api :POST, '/task_item_records/:id/complete', 'Complete task item record'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    param :id, Integer, required: true
    param :category, String
    param :task_item_record, Hash, required: true do
      param :comment, String
      param :status, String, 'Must be completed or empty string.'
    end

    description <<-EOS
      If successful, it returns a json containing <tt>task item record object</tt>.

      If task_item_record is category, please send <tt>category</tt> parameter as <tt>yes</tt>.
      If you need to complete task item, you must send <tt>completed</tt> on status parameter. Please check parameter section.

      TaskItemRecord object contains:
        id: id
        user: User object
        created_by: User object
        updated_by: User Object
        comment: Completion comment
        completed_at: Completed time
        created_at: Created Time
        updated_at: Updated Time
        title: Title
        image_url: Optional image url
    EOS
  end

  doc_for :reset do
    api :POST, '/task_item_records/:id/reset', 'Reset task item record'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    param :id, Integer, required: true
    param :category, String

    description <<-EOS
      If successful, it returns a json containing <tt>task item record object</tt>.

      If task_item_record is category, please send <tt>category</tt> parameter as <tt>yes</tt>.

      TaskItemRecord object contains:
        id: id
        user: User object
        created_by: User object
        updated_by: User Object
        comment: Completion comment
        completed_at: Completed time
        created_at: Created Time
        updated_at: Updated Time
        title: Title
        image_url: Optional image url
    EOS
  end
end
