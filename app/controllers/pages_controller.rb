class PagesController < ApplicationController
  include PermissionsHelper
  include S3SignMethods

  respond_to :html

  skip_before_action :authenticate_web_access, only: :home
  before_action :load_requests_orders_and_lists, only: [:dashboard]

  def dashboard
    @pos = PurchaseOrderDecorator.decorate_collection @pos
    @requests_and_orders = @prs + @pos
    @requests_and_orders = @requests_and_orders.sort_by {|ro| ro.state }
  end

  def setup
  end

  def spend_vs_budgets_data
    time_from = params[:range] == 'year' ? Time.now.beginning_of_year : Time.now.beginning_of_month
    @budget_spend_data = {
      data: { budget:[], spend: []},
      categories: []
    }
    Category.includes(:items).load.each do |category|
      item_ids = category.item_ids
      next if item_ids.count == 0
      spend  = PurchaseReceipt.include_items(item_ids).where(created_at: time_from..Time.now).map{ |receipt| receipt.total(item_ids) }.reduce(&:+).to_f
      budget = category.budgets.where(created_at: Time.now.beginning_of_year..Time.now).sum(:amount).to_f
      next if !spend && !budget
      @budget_spend_data[:categories] << category.name
      @budget_spend_data[:data][:budget] << budget
      @budget_spend_data[:data][:spend] << spend
    end
    render json: @budget_spend_data.to_json
  end

  def home
    if user_signed_in?
      if current_user.corporate? && Property.current.nil?
        redirect_to :corporate_root
      elsif current_user.permission_attributes.level2.access_attributes.count == 1
        redirect_to priority_path
      elsif policy(:access).maintenance?
        redirect_to :maintenance_root
      else
        redirect_to dashboard_path
      end
    else
      render layout: false
    end
  end

  def s3_sign
    object_name = params[:objectName]
    if object_name.blank?
      render json: {error: 'objectName parameter is blank.'}, status: 422
      return
    end

    upload_type = params[:uploadType]
    if upload_type.blank?
      render json: {error: 'uploadType parameter is blank.'}, status: 422
      return
    end

    unless (upload_type == 'image' || upload_type == 'photo' || upload_type == 'video')
      render json: {error: 'uploadType must be one of image, photo, or video'}, status: 422
      return
    end

    bucket_name = Settings.lodigstics_s3_bucket_name
    region = Settings.lodgistics_s3_region
    s3_key = "#{upload_type}s/upload/#{SecureRandom.uuid}_#{object_name}"
    s3FileUrl = "https://#{bucket_name}.s3.#{region}.amazonaws.com/" + s3_key
    render json: { signedUrl: get_signed_url(s3_key), filename: s3_key, s3FileUrl: s3FileUrl }
  end

  private

  def load_requests_orders_and_lists
    @prs = PurchaseRequest.order(updated_at: :asc).without_inventory_finished.where.not(state: 'ordered')
    @pos = PurchaseOrder.order(updated_at: :asc).where(closed_at: nil)

    if current_user.current_property_role == Role.manager
      @prs = @prs.where(user: current_user)
      @pos = @pos.where("user_id=? OR purchase_request_id IN (?)", current_user.id, current_user.purchase_request_ids)
      @lists = List.where(user: current_user).top_six_for_user(current_user)
    else
      @lists = List.top_six_for_user(current_user)
    end
  end

  def get_signed_url(s3_key)
    bucket_name = Settings.lodigstics_s3_bucket_name
    region = Settings.lodgistics_s3_region
    aws_access_key_id = Settings.lodigstics_aws_access_key
    aws_secret_access_key = Settings.lodigstics_aws_secret_access_key
    s3 = Aws::S3::Resource.new(region: region, access_key_id: aws_access_key_id, secret_access_key: aws_secret_access_key)
    obj = s3.bucket(bucket_name).object(s3_key)
    put_url = obj.presigned_url(:put, acl: 'public-read', expires_in: 3600 * 24)
    put_url
  end

end
