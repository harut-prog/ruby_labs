require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "authenticated static pages" do
    user = User.create!(email: "pages-test@example.org", password: "test-password-123", role: "reader")
    sign_in user
    [root_path, about_path, contact_path].each do |path|
      get path
      assert_response :success
    end
  end

  test "anonymous user must sign in" do
    get root_path
    assert_redirected_to new_user_session_path
  end
end
