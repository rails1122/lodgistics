class SchedulesController < ApplicationController
  def create
    @schedule = Schedule.new schedule_params
    @schedule.save
  end

  def update
    @schedule = Schedule.find params[:id]
    @schedule.deleted_at = Time.now
    @schedule.save

    @schedule = Schedule.new(schedule_params)
    if @schedule.save
      @work_order = @schedule.generate_next_occurrence
    end
  end

  def destroy
    @schedule = Schedule.find params[:id]
    @schedule.deleted_at = Time.now
    @schedule.save
    @upcomings = @schedule.occurrences.upcoming.destroy_all
    @work_order = @schedule.eventable
    @schedule = @schedule.eventable.try(:build_schedule) || Schedule.new
  end

  private

  def schedule_params
    params.require(:schedule).permit(:eventable_type, :eventable_id, :start_date, 
      :end_date, :interval, :recurring_type, days: [])
  end
end