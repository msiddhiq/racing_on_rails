# Public page of all Teams
class TeamsController < ApplicationController
  def index
    if RacingAssociation.current.show_all_teams_on_public_page?
      @teams = Team.all
    else
      @teams = Team.where(member: true).where(show_on_public_page: true)
    end
    @discipline_names = Discipline.names
  end
end
