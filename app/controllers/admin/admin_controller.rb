class Admin::AdminController < ApplicationController
  force_https
  before_filter :require_administrator, :assign_current_admin_tab

  layout "admin/application"

  # Always show tabs
  def toggle_tabs
    @show_tabs = true
  end

  protected

  def assign_current_admin_tab
    @current_admin_tab = nil
  end
end
