class Report::WorkOrderSerializer < ActiveModel::Serializer
  attributes :id, :description, :priority, :status, :days_elapsed, :closed_at
  attributes :assigned_to_name, :opened_by_name, :closed_by_name

  def closed_at
    I18n.l(object.closed_at, format: :short) if object.closed_at
  end

  def assigned_to_name
    object.assigned_to_name
  end

  def opened_by_name
    object.opened_by&.name
  end

  def closed_by_name
    object.closed_by&.name
  end
end
