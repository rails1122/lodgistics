class Engage::DashboardController < ApplicationController
  around_action :property_time_zone
  add_breadcrumb I18n.t('controllers.engage.dashboard'), :engage_dashboard_path

  def index
    gon.users_in_property = (Property.current.users.active - [ current_user ]).map { |i| { id: i.id, name: i.name } }
    respond_to do |format |
      format.html {}
      format.pdf do
        @date = Date.parse(params[:date] || Date.today.to_s)
        @messages = Engage::Message.for_property_id(Property.current_id).threads.occurred_on(@date).as_json(user: current_user, date: @date)
        @follow_ups = @messages.select { |msg| msg[:follow_up_show] }
        @messages = @messages - @follow_ups

        @alarms = Engage::Entity.alarm(@date).as_json(user: current_user, date: @date)

        title = format("Front Desk Log")
        render pdf: title,
               template: 'engage/dashboard/index',
               layout: 'layouts/pdf.html.haml',
               header: {
                 html: {
                   template: 'reports/pdf/header',
                   locals: {
                     report_title: title
                   }
                 }
               },
               footer: {
                 center: '[page] of [topage]'
               }
      end
    end
  end
end
