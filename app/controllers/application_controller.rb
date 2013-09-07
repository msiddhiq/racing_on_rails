class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  
  include ActionController::ForceHTTPS
  include RacingOnRails::Controllers::Authorization
  include RacingOnRails::Controllers::Authentication
  include RacingOnRails::Controllers::Mobile
  include SentientController


  before_filter :clear_racing_association, :toggle_tabs, :assign_year

  def self.expire_cache
    begin
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "bar"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "cat4_womens_race_series"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "competitions"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "events"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "people"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "m"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "rider_rankings"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "results"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "schedule"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "teams"))
      FileUtils.rm_rf(File.join(::Rails.root.to_s, "public", "wsba_barr"))
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "bar.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "cat4_womens_race_series.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "home.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "index.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "m.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "results.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "rider_rankings.html"), :force => true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.html"), :force =>true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.ics"), :force =>true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.atom"), :force =>true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "schedule.xls"), :force =>true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "teams.html"), :force =>true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "wsba_barr.html"), :force =>true)
      FileUtils.rm(File.join(::Rails.root.to_s, "public", "wsba_masters_barr.html"), :force =>true)
    rescue Exception => e
      logger.error e
    end
    
    true
  end


  protected
  
  def clear_racing_association
    RacingAssociation.current = nil
  end
  
  def toggle_tabs
    @show_tabs = false
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

    @page = find_mobile_page(page_path)
    
    if !@page
      @page = Page.find_by_path(page_path)
    end

    if @page
      render(:inline => @page.body, :layout => true)
    end
  end

  def render_404
    respond_to do |type|
      type.html {
        local_path = "#{Rails.root}/local/public/404.html"
        if File.exists?(local_path)
          render :file => "#{::Rails.root.to_s}/local/public/404.html", :status => "404 Not Found"
        else
          render :file => "#{::Rails.root.to_s}/public/404.html", :status => "404 Not Found"
        end
      }
      type.all { render :nothing => true, :status => "404 Not Found" }
    end
  end

  def render_500
    respond_to do |type|
      type.html {
        local_path = "#{Rails.root}/local/public/500.html"
        if File.exists?(local_path)
          render :file => "#{::Rails.root.to_s}/local/public/500.html", :status => "500 Error"
        else
          render :file => "#{::Rails.root.to_s}/public/500.html", :status => "500 Error"
        end
      }
      type.all { render :nothing => true, :status => "500 Error" }
    end
  end
  
  def assign_year
    if params[:year] && params[:year][/^\d\d\d\d$/]
      @year = params[:year].to_i
    end
    
    if @year.nil? || @year < 1900 || @year > 2100
      @year = RacingAssociation.current.effective_year
    end
  end

  private
  
  def secure_redirect_options
    if RacingAssociation.current.ssl?
      { :protocol => "https", :host => request.host }
    else
      {}
    end
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
