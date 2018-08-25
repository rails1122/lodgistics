module Api::TaskListRecordsDoc
  extend BaseDoc

  namespace 'api'
  resource :task_list_records

  doc_for :show do
    api :GET, '/task_list_records/:id', 'Get TaskListRecord detail'
    error 400, 'Not Found'
    error 500, 'Server Error'

    param :id, Integer, required: true

    description  <<-EOS
      If successful, it returns a json containing <tt>task list record object</tt>.

      TaskListRecord object contains:
        id: id
        user: User object
        finished_by: User Object
        finished_at: Finished time(Reviewed time)
        review_notified_at: Time when review request sent
        reviewer_notes: Notes from review
        started_at: Started Time
        notes: Notes
        created_at: Created Time
        updated_at: Updated Time
        task_list: TaskList object
        categories: TaskItem objects grouped by category
        reviewed_at: Time this item was reviewed
        reviewed_by: user who reviewed this item
    EOS
  end

  doc_for :finish do
    api :POST, '/task_list_records/:id/finish', 'Finish task list record'
    error 401, 'Unauthorized'
    error 500, 'Server Error'

    param :id, Integer, required: true

    description <<-EOS
      If successful, it returns a json containing <tt>task list record object</tt>.

      TaskListRecord object contains:
        id: id
        user: User object
        started_at: Started Time
        notes: Notes
        created_at: Created Time
        updated_at: Updated Time
        task_list: TaskList object
        categories: TaskItem objects grouped by category
    EOS
  end

  doc_for :review do
    api :POST, '/task_list_records/:id/review', 'Finish task list record'
    error 401, 'Unauthorized'
    error 500, 'Server Error'

    param :id, Integer, required: true
    param :status, String, '<tt>reviewed</tt> or empty string'

    description <<-EOS
      If successful, it returns a json containing <tt>task list record review object</tt>.

      TaskListRecord object contains:
        id: id
        reviewed_by: User object
        reviewed_at: Started Time
        reviewer_notes: Reviewer Notes
    EOS
  end
end
