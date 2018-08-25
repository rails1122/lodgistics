class OccurrencesController < ApplicationController
  def create
    @occurrence = Occurrence.find_or_initialize_by(
      schedule_id: params[:occurrence][:schedule_id], 
      date: params[:occurrence][:date]
    )
    @occurrence.update_attributes(occurrence_params)
    @schedule = @occurrence.schedule

    render 'schedules/update'
  end

  private
  def occurrence_params
    params.require(:occurrence).permit(:status, :date, :index, :schedule_id, option: [:assigned_to_id ])
  end
end