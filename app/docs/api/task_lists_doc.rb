module Api::TaskListsDoc
  extend BaseDoc

  namespace 'api'
  resource :task_lists

  doc_for :index do
    api :GET, '/task_lists', 'Get available task_lists for current user (current user is set based on token in request header)'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns a json containing <tt>a list of active task_list object</tt>

      task_list object contains:
        id: id
        property_id: property_id
        name: name
        description: description
        notes: notes
        task_list_record_id: id for task_list_record started by current user
        started_at: when this task list was started by current user
        updated_at: when this task list was updatd by current user
    EOS
  end

  doc_for :activities do
    api :GET, '/task_lists/activities', 'Get task list activities - return info about finished task list records'
    error 401, 'Unauthorized'
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns a json containing <tt>a list of active task_list_activity object</tt>

      task_list_activity object contains:
        task_list_id: task_list id
        finished_at: when this task_list_record was finished
        finished_by: user who finished task_list_record
        status: status for this task_list_record
        reviewer_notes: reviewer notes
        reviewed_at: Time this item was reviewed
        reviewed_by: user who reviewed this item
    EOS

    param :finished_after, String, "returns data finished after given yyyy-mm-dd hh:mm:ss +z. (is08601 format is recommended) if no timezone given, it will be parsed into UTC."
    param :limit, Integer, "# of items to be returned. 10 if not given"
  end

  doc_for :start_resume do
    api :POST, '/task_lists/:id/start_resume', 'Start/Resume task list'

    param :task_list_record_id, Integer

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

      Here's example response
        {
          "id"=>1,
          "started_at"=>"2018-03-15T07:58:51.201-04:00",
          "status"=>"started",
          "notes"=>nil,
          "created_at"=>"2018-03-15T07:58:51.202-04:00",
          "updated_at"=>"2018-03-15T07:58:51.202-04:00",
          "categories"=>[
            {
              "id"=>1,
              "completed_at"=>nil,
              "comment"=>nil,
              "created_at"=>"2018-03-15T07:58:51.230-04:00",
              "updated_at"=>"2018-03-15T07:58:51.230-04:00",
              "title"=>"Dolorum nemo ut qui inventore reiciendis tempora ducimus tenetur.",
              "image_url"=>nil,
              "user"=>{"id"=>1, "name"=>"Barney Pfannerstill", "email"=>"julius@cummingtokes.com"},
              "created_by"=>{"id"=>1, "name"=>"Barney Pfannerstill", "email"=>"julius@cummingtokes.com"},
              "updated_by"=>nil,
              "item_records"=>[
                {
                  "id"=>3,
                  "completed_at"=>nil,
                  "comment"=>nil,
                  "created_at"=>"2018-03-15T07:58:51.241-04:00",
                  "updated_at"=>"2018-03-15T07:58:51.241-04:00",
                  "title"=>"Perspiciatis provident ut sit.",
                  "image_url"=>nil,
                  "user"=>{"id"=>1, "name"=>"Barney Pfannerstill", "email"=>"julius@cummingtokes.com"},
                  "created_by"=>{"id"=>1, "name"=>"Barney Pfannerstill", "email"=>"julius@cummingtokes.com"},
                  "updated_by"=>nil
                },
                {
                  "id"=>2,
                  "completed_at"=>nil,
                  "comment"=>nil,
                  "created_at"=>"2018-03-15T07:58:51.235-04:00",
                  "updated_at"=>"2018-03-15T07:58:51.235-04:00",
                  "title"=>"Tempore totam quia commodi molestiae incidunt ut repellat et.",
                  "image_url"=>nil,
                  "user"=>{"id"=>1, "name"=>"Barney Pfannerstill", "email"=>"julius@cummingtokes.com"},
                  "created_by"=>{"id"=>1, "name"=>"Barney Pfannerstill", "email"=>"julius@cummingtokes.com"},
                  "updated_by"=>nil
                }
              ]
            }
          ]
        }
    EOS
  end

end
