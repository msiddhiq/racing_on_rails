class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable  
  
  local_addresses.clear
  
  RESULTS_LIMIT = 100
  
  # HP's proxy, among others, gets this wrong
  ActionController::Base.ip_spoofing_check = false

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  def self.expire_cache
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'results'))
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'bar'))
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'public', 'schedule'))
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'results.html'), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'schedule.html'), :force =>true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'index.html'), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'home.html'), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, 'public', 'bar.html'), :force => true)
  end

  def expire_cache
    if perform_caching
      ApplicationController.expire_cache
    end
  end

  def render_page(path = nil)
    unless path
      path = controller_path
      path = "#{path}/#{action_name}" unless action_name == "index"
    end
    
    page_path = path.dup
    page_path.gsub!(/.html$/, "")
    page_path.gsub!(/index$/, "")
    page_path.gsub!(/\/$/, "")

    @page = Page.find_by_path(page_path)
    if @page
      return render(:inline => @page.body, :layout => true)
    end
  end

  def rescue_action(exception)
    respond_to do |format|
      format.html {
        rescue_with_handler(exception) || rescue_action_without_handler(exception)
      }
      format.js {
        log_error(exception)
        ExceptionNotifier.deliver_exception_notification(exception, self, request, {})
        render "shared/exception", :locals => { :exception => exception }
      }
      format.all {
        rescue_with_handler(exception) || rescue_action_without_handler(exception)
      }
    end
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_administrator
    unless current_user && current_user.administrator?
      store_location
      flash[:notice] = "You must be an administrator to access this page"
      redirect_to new_user_session_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
