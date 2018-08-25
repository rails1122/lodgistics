module AdminHelper
  def admin_customers_menu_active?
    params[:controller] == 'admin/customers'
  end
end