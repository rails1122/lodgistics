# require "test_helper"

# describe Schedule do

#   it 'should generate daily schedule' do
#     work_order = Maintenance::WorkOrder.create
#     schedule = Schedule.new
#     schedule.eventable = work_order
#     schedule.rules = IceCube::Schedule.new(Date.parse('2015-01-05'), end_time: Date.parse('2015-01-10')) do |s|
#       s.add_recurrence_rule IceCube::Rule.daily(1).until(Date.parse('2015-01-10'))
#     end
#     schedule.save

#     Timecop.travel(Time.parse('2015-01-05')) do
#       schedule.occurrences[:past].count.must_equal 0
#       schedule.occurrences[:upcoming].count.must_equal 6
#     end

#     Timecop.travel(Time.parse('2015-01-07')) do
#       schedule.occurrences[:past].count.must_equal 2
#       schedule.occurrences[:upcoming].count.must_equal 4
#     end

#     Timecop.travel(Time.parse('2015-01-11')) do
#       schedule.occurrences[:past].count.must_equal 6
#       schedule.occurrences[:upcoming].count.must_equal 0
#     end
#   end

#   it 'should generate weekly schedule' do
#     work_order = Maintenance::WorkOrder.create
#     schedule = Schedule.new
#     schedule.eventable = work_order
#     schedule.rules = IceCube::Schedule.new(Date.parse('2015-11-01'), end_time: Date.parse('2015-11-30')) do |s|
#       s.add_recurrence_rule IceCube::Rule.weekly(1).day(:monday, :friday).until(Date.parse('2015-11-30'))
#     end
#     schedule.save!
#     schedule.reload

#     Timecop.travel(Time.parse('2015-11-01')) do
#       schedule.occurrences[:past].count.must_equal 0
#       schedule.occurrences[:upcoming].count.must_equal 9
#     end

#     Timecop.travel(Time.parse('2015-11-09')) do
#       schedule.occurrences[:past].count.must_equal 2
#       schedule.occurrences[:upcoming].count.must_equal 7
#     end

#     Timecop.travel(Time.parse('2015-12-1')) do
#       schedule.occurrences[:past].count.must_equal 9
#       schedule.occurrences[:upcoming].count.must_equal 0
#     end
#   end

#   it 'should generate monthly schedule' do
#     work_order = Maintenance::WorkOrder.create
#     schedule = Schedule.new
#     schedule.eventable = work_order
#     schedule.rules = IceCube::Schedule.new(Date.parse('2015-01-01'), end_time: Date.parse('2015-12-31')) do |s|
#       s.add_recurrence_rule IceCube::Rule.monthly(1).day_of_month(10).until(Date.parse('2015-12-31'))
#     end
#     schedule.save
#     schedule.reload

#     Timecop.travel(Time.parse('2015-01-01')) do
#       schedule.occurrences[:past].count.must_equal 0
#       schedule.occurrences[:upcoming].count.must_equal 12
#     end

#     Timecop.travel(Time.parse('2015-06-09')) do
#       schedule.occurrences[:past].count.must_equal 5
#       schedule.occurrences[:upcoming].count.must_equal 7
#     end

#     Timecop.travel(Time.parse('2015-12-31')) do
#       schedule.occurrences[:past].count.must_equal 12
#       schedule.occurrences[:upcoming].count.must_equal 0
#     end
#   end

#   it 'should skip specific recurring orders' do
#     work_order = Maintenance::WorkOrder.create
#     schedule = Schedule.new
#     schedule.eventable = work_order
#     schedule.rules = IceCube::Schedule.new(Date.parse('2015-11-01'), end_time: Date.parse('2015-11-30')) do |s|
#       s.add_recurrence_rule IceCube::Rule.daily(1).until(Date.parse('2015-11-30'))
#     end
#     schedule.options = {
#       '2015-11-02' => {status: Schedule::STATUS_SKIP},
#       '2015-11-12' => {status: Schedule::STATUS_SKIP}
#     }
#     schedule.save
#     schedule.reload

#     Timecop.travel(Time.parse('2015-11-01')) do
#       events = schedule.occurrences
#       events[:past].count.must_equal 0
#       events[:upcoming].count.must_equal 30
#       events[:upcoming].select { |e| e[:option][:status] == Schedule::STATUS_SKIP }.count.must_equal 2
#     end
#   end

#   it 'should have default values for each recurring' do
#     u1 = create(:user)
#     u2 = create(:user)
#     work_order = Maintenance::WorkOrder.create
#     schedule = Schedule.new
#     schedule.eventable = work_order
#     schedule.rules = IceCube::Schedule.new(Date.parse('2015-11-01'), end_time: Date.parse('2015-11-30')) do |s|
#       s.add_recurrence_rule IceCube::Rule.daily(1).until(Date.parse('2015-11-30'))
#     end
#     schedule.options = {
#       '2015-11-02' => {assigned_to: u1.id},
#       '2015-11-12' => {assigned_to: u2.id}
#     }
#     schedule.save
#     schedule.reload

#     Timecop.travel(Time.parse('2015-11-01')) do
#       events = schedule.occurrences
#       first = events[:upcoming].select { |e| e[:date] == '2015-11-02' }[0]
#       first[:option][:assigned_to].must_equal u1.id
#       first[:option][:assigned_name].must_equal u1.name

#       second = events[:upcoming].select { |e| e[:date] == '2015-11-12' }[0]
#       second[:option][:assigned_to].must_equal u2.id
#       second[:option][:assigned_name].must_equal u2.name

#       third = events[:upcoming].select { |e| e[:date] == '2015-11-22' }[0]
#       third[:option][:assigned_to].must_equal nil
#       third[:option][:assigned_name].must_equal nil
#     end
#   end

# end