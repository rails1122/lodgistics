require 'test_helper'

class PagesRouteTest < ActionDispatch::IntegrationTest
  def test
    assert_generates "/s3_sign", :controller => "pages", :action => "s3_sign"
  end
end
