class WorkOrderSerializer < ActiveModel::Serializer
  attributes :id, :property_id, :description, :priority, :status, :due_to_date,
    :assigned_to_id, :maintainable_type, :other_maintainable_location, :maintainable_id, :opened_by_user_id,
    :created_at, :updated_at, :closed_by_user_id, :first_img_url, :second_img_url, :work_order_url,
    :opened_at, :closed, :closed_at

  def closed
    object.closed?
  end

  def first_img_url
    object.first_img_url
  end

  def second_img_url
    object.second_img_url
  end

  def work_order_url
    object.resource_url
  end
end
