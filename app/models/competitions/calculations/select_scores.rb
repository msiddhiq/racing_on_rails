module Competitions
  module Calculations
    module SelectScores
      # Select only scores with points and a participant up to +maximum_events+
      def select_scores(scores, rules)
        selected_scores = scores.select { |s| points?(s) && s.participant_id }

        if maximum_events?(rules)
          # Upgrades don't count towards maximum events
          # Calculator needs to model results as map keyed by category, not an array,
          # to improve this code
          upgrades = selected_scores.select { |s| s.upgrade }
          reject_scores_greater_than_maximum_events(selected_scores.select { |s| !s.upgrade }, rules) +
          upgrades
        else
          selected_scores
        end
      end

      def points?(score)
        score.points && score.points > 0.0
      end

      def maximum_events?(rules)
        rules[:maximum_events] != UNLIMITED
      end

      def reject_scores_greater_than_maximum_events(scores, rules)
        scores.group_by(&:participant_id).
        map do |participant_id, participant_scores|
          slice_of participant_scores, rules[:maximum_events]
        end.
        flatten
      end

      def slice_of(scores, maximum)
        scores.
        group_by(&:event_id).
        sort_by do |event_id, event_scores|
          event_scores.map { |s| s.points }.reduce(&:+)
        end.
        reverse[ 0, maximum ].
        map(&:last)
      end
    end
  end
end
