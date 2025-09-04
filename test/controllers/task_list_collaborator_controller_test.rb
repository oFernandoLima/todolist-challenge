require "test_helper"

class TaskListCollaboratorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get task_list_collaborator_index_url
    assert_response :success
  end

  test "should get show" do
    get task_list_collaborator_show_url
    assert_response :success
  end

  test "should get new" do
    get task_list_collaborator_new_url
    assert_response :success
  end

  test "should get edit" do
    get task_list_collaborator_edit_url
    assert_response :success
  end
end
