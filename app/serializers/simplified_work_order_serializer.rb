class SimplifiedWorkOrderSerializer < ActiveModel::Serializer
  attributes :id, :description, :created_at, :opened_at, :opened_by_user_id, :created_by_user_id,
    :closed_at, :closed_by_user_id, :first_img_url, :second_img_url, :location_detail

  def created_by_user_id
    object.opened_by_user_id
  end

  def opened_at
    object.created_at
  end

  def first_img_url
    object.first_img_url
  end

  def second_img_url
    object.second_img_url
  end

  def location_detail
    object.location_detail
  end
end
