require "test_helper"

class DailyPlanningControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get daily_planning_edit_url
    assert_response :success
  end

  test "should get update" do
    get daily_planning_update_url
    assert_response :success
  end
end
