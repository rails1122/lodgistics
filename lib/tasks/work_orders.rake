namespace :work_orders do
  desc 'Populate localtion name'
  task populate_location_name: :environment do
    Property.all.each do |p|
      p.run_block do
        Maintenance::WorkOrder.all.each do |wo|
          wo.location_name = wo.get_location_name
          wo.save(validate: false)
        end
      end
    end
  end
end