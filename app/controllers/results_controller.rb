class ResultsController < ApplicationController
  caches_page :index, :event, :competition, :racer, :team, :show
  
  def index
    # TODO Create helper method to return Range of first and last of year
    @year = params['year'].to_i
    @year = Date.today.year if @year == 0
    @discipline = Discipline[params['discipline']]
    @discipline_names = Discipline.find_all_names
    @weekly_series, @events = Event.find_all_with_results(@year, @discipline)
  end
  
  def event
    @event = Event.find(
      params[:id],
      :include => [:races => {:results => {:racer, :team}} ]
    )
    if @event.is_a?(Bar)
      redirect_to(:controller => 'bar', :action => 'show', :year => @event.year)
    elsif @event.is_a? Ironman
      redirect_to ironman_path(:year => @event.year)
    end
  end

  def competition
    @competition = Event.find(params[:competition_id])
    if !params[:racer_id].blank?
      @results = Result.find(
        :all,
        :include => [:racer, {:race => :event }],
        :conditions => ['events.id = ? and racers.id = ?', params[:competition_id], params[:racer_id]]
      )
      @racer = Racer.find(params[:racer_id])
    else
      @results = Result.find(
        :all,
        :include => [{:race => :event }, :team],
        :conditions => ['events.id = ? and teams.id = ?', params[:competition_id], params[:team_id]]
      )
      
      result_ids = @results.collect {|result| result.id}
      @scores = Score.find(
        :all,
        :include => [{:source_result => [:racer, {:race => [:category, :event ]}]}],
        :conditions => ['competition_result_id in (?)', result_ids]
      )
      @team = Team.find(params[:team_id])
      return render(:template => 'results/team_competition')
    end
  end
  
  def racer
    @racer = Racer.find(params[:id])
    results = Result.find(
      :all,
      :include => [:team, :racer, :scores, :category, { :race => :event, :race => :category }],
      :conditions => ['racers.id = ?', params[:id]]
    )
    @competition_results, @event_results = results.partition do |result|
      result.event.is_a?(Competition)
    end
  end
  
  def team
    @team = Team.find(params[:id])
    redirect_to(team_path(@team), :status => :moved_permanently)
  end

  def show
    result = Result.find(params[:id])
    if result.racer
      redirect_to(:action => 'competition', :competition_id => result.event.id, :racer_id => result.racer_id)    
    elsif result.team
      redirect_to(:action => 'competition', :competition_id => result.event.id, :team_id => result.team.id)    
    else
      redirect_to(:action => 'competition', :competition_id => result.event.id)
    end
  end
end
