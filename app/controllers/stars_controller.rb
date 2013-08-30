class StarsController < ApplicationController
  force_https
  before_filter :require_current_person, :only => :create

  def create
    respond_to do |format|
      format.json do
        current_person.stars.create! :event_id => params[:star][:event_id]
        render :json => "ok"
      end
    end
  end
  
  def index
    respond_to do |format|
      format.json do
        if current_person
          render :json => Star.where(:person_id => current_person.id).pluck(:event_id)
        else
          render :json => []
        end
      end
    end
  end
end

