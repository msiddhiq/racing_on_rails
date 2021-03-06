class TeamObserver < ActiveRecord::Observer
  def after_destroy(team)
    Result.where(team_id: team.id).update_all(team_id: nil, team_name: nil, team_member: false)
    true
  end

  def after_update(team)
    if team.name_changed? || team.member_changed?
      team.results.each do |result|
        if result.team_name != team.name(result.year) || result.team_member? != team.member?
          result.cache_attributes! :non_event
        end
      end
    end
    true
  end
end
