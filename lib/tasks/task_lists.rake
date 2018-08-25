namespace :task_lists do
  desc "Load default task lists"
  task load_defaults: :environment do
    property_names = ['HGI - Test Property 1', 'Parks Hospitality', 'Test Hotel 1', 'Test Hotel 2']
    properties = Property.where(name: property_names)

    loader = TaskListLoader.new('task_lists.yml')
    loader.load_data!(properties)
  end
end