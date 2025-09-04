class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_nav_notifications

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def after_sign_in_path_for(_resource)
    authenticated_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    unauthenticated_root_path
  end

  private

  def set_nav_notifications
    return unless user_signed_in?
    @pending_invites_count =
      if current_user.respond_to?(:task_list_collaborations)
        current_user.task_list_collaborations.pending.count
      else
        0
      end
  end
end
