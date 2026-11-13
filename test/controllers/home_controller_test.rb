require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "authenticated home" do
    user = User.create!(email: "home-test@example.org", password: "test-password-123", role: "reader")
    sign_in user
    get root_path
    assert_response :success
  end
end
