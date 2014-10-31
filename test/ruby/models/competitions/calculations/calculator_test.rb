require_relative "../../../../../app/models/competitions/calculations/calculator"
require_relative "calculations_test"

# :stopdoc:
# TODO remove noisy member setup
module Competitions
  module Calculations
    class CalculatorTest < CalculationsTest
      def test_calculate_with_no_source_results
        assert_equal [], Calculator.calculate([])
      end

      def test_calculate_with_one_source_result
        source_results = [ { "event_id" => 1, "participant_id" => 1, "place" => "1", "member_from" => Date.new(2012), member_to: end_of_year, "year" => Date.today.year } ]
        expected = [
          result(place: 1, participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1 } ])
        ]
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_with_many_source_results
        source_results = [
          { event_id: 1, participant_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { event_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 1, scores: [ { numeric_place: 1, participant_id: 1, points: 1 } ]),
          result(place: 1, participant_id: 2, points: 1, scores: [ { numeric_place: 2, participant_id: 2, points: 1 } ])
        ]
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_team_results
        source_results = [
          { race_id: 1, participant_id: 3, place: 1, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { race_id: 1, participant_id: 4, place: 1, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { race_id: 1, participant_id: 1, place: 2, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year },
          { race_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, year: Date.today.year }
        ]
        expected = [
          result(place: 3, participant_id: 1, points: 4, scores: [ { numeric_place: 2, participant_id: 1, points: 4 } ]),
          result(place: 3, participant_id: 2, points: 4, scores: [ { numeric_place: 2, participant_id: 2, points: 4 } ]),
          result(place: 1, participant_id: 3, points: 10, scores: [ { numeric_place: 1, participant_id: 3, points: 10 } ]),
          result(place: 1, participant_id: 4, points: 10, scores: [ { numeric_place: 1, participant_id: 4, points: 10 } ])
        ]
        actual = Calculator.calculate(source_results, point_schedule: [ 20, 8, 3 ])
        assert_equal_results expected, actual
      end

      def test_calculate_team_results_best_3_for_event
        source_results = [
          { event_id: 1, race_id: 1, participant_id: 1, place: 107 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 7 },
          { event_id: 1, race_id: 1, participant_id: 2, place: 1 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 2 },
          { event_id: 1, race_id: 1, participant_id: 2, place: 8 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 3 },
          { event_id: 1, race_id: 1, participant_id: 1, place: 4 },
          { event_id: 2, race_id: 2, participant_id: 1, place: 1 }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 34, scores: [
            { numeric_place: 1, participant_id: 1, points: 10 },
            { numeric_place: 2, participant_id: 1, points: 9 },
            { numeric_place: 3, participant_id: 1, points: 8 },
            { numeric_place: 4, participant_id: 1, points: 7 }
          ]),
          result(place: 2, participant_id: 2, points: 13, scores: [
            { numeric_place: 1, participant_id: 2, points: 10 },
            { numeric_place: 8, participant_id: 2, points: 3 }
          ])
        ]
        actual = Calculator.calculate(
          source_results,
          point_schedule: [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ],
          results_per_event: 3,
          results_per_race: UNLIMITED,
          members_only: false
        )
        assert_equal_results expected, actual
      end

      def test_calculate_should_ignore_non_scoring_results
        source_results = [
          { event_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
        ]
        expected = []
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_ignore_non_starters
        source_results = [
          { event_id: 1, participant_id: 1, place: "", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 2, place: "DNS", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 3, place: "DQ", member_from: Date.new(2012), member_to: end_of_year },
          { event_id: 1, participant_id: 4, place: nil, member_from: Date.new(2012), member_to: end_of_year }
        ]
        expected = []
        actual = Calculator.calculate(source_results)
        assert_equal_results expected, actual
      end

      def test_calculate_with_multiple_events_and_people
        source_results = [
          { id: 1, event_id: 1, race_id: 1, participant_id: 1, place: 1, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
          { id: 2, event_id: 1, race_id: 1, participant_id: 2, place: 2, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
          { id: 3, event_id: 1, race_id: 1, participant_id: 2, place: 20, member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year },
          { id: 4, event_id: 2, race_id: 2, participant_id: 1, place: "DNF", member_from: Date.new(2012), member_to: end_of_year, "year" => Date.today.year }
        ]
        expected = [
          result(place: 1, participant_id: 1, points: 2, scores: [ { numeric_place: 1, source_result_id: 1, points: 1, participant_id: 1 }, { numeric_place: Float::INFINITY, source_result_id: 4, points: 1, participant_id: 1 } ]),
          result(place: 2, participant_id: 2, points: 1, scores: [ { numeric_place: 2, source_result_id: 2, points: 1, participant_id: 2 } ])
        ]
        actual = Calculator.calculate(source_results, dnf: true)
        assert_equal_results expected, actual
      end
  
      def test_team_membership
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "200",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: false),

          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: "6",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: true)
        ]
        actual = Calculator.select_results(source_results, { results_per_event: 1, results_per_race: 1 })
        assert_equal [ 2 ], actual.map(&:id)
      end

      def test_no_team_membership
        source_results = [
          result(id: 1, event_id: 1, race_id: 1, participant_id: 1, place: "200",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: false),

          result(id: 2, event_id: 1, race_id: 1, participant_id: 1, place: "6",
            member_from: Date.new(2012), member_to: end_of_year, year: 2013, team_member: true)
        ]
        actual = Calculator.select_results(
          source_results, { 
            results_per_event: UNLIMITED,
            results_per_race: UNLIMITED
        })
        assert_equal [ 1, 2 ], actual.map(&:id).sort
      end

      def test_map_to_scores
        expected = [ Struct::CalculatorScore.new(nil, 5, 4, 1, 1, nil) ]
        source_results = [ result(id: 1, race_id: 3, participant_id: 4, place: 5, member_from: Date.new(2012)) ]
        actual = Calculator.map_to_scores(source_results, {})
        assert_equal expected, actual
      end

      def test_map_to_scores_empty
        expected = []
        actual = Calculator.map_to_scores([], {})
        assert_equal expected, actual
      end

      def test_map_to_results
        scores = [ Struct::CalculatorScore.new(nil, 2, 3, 4, 5) ]
        expected = [ result(participant_id: 3, points: 4, scores: [ { numeric_place: 2, participant_id: 3, points: 4, source_result_id: 5 } ]) ]
        actual = Calculator.map_to_results(scores)
        assert_equal_results expected, actual
      end

      def test_map_to_results_empty
        expected = []
        actual = Calculator.map_to_results([])
        assert_equal expected, actual
      end

      def test_points
        assert_equal 1, Calculator.points(result(place: 20), break_ties: false)
      end

      def test_points_with_point_schedule
        rules = { point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] }
        assert_equal 0, Calculator.points(result(place: "20"), rules)
        assert_equal 1, Calculator.points(result(place: "15"), rules)
        assert_equal 14, Calculator.points(result(place: 2), rules)
        assert_equal 0, Calculator.points(result(place: ""), rules)
        assert_equal 0, Calculator.points(result(place: nil), rules)
        assert_equal 0, Calculator.points(result(place: "DNF"), rules)
        assert_equal 0, Calculator.points(result(place: "DQ"), rules)
      end

      def test_points_considers_team_size
        rules = { point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] }
        assert_equal 0, Calculator.points(result(place: "20", team_size: 2), rules)
        assert_equal 0.5, Calculator.points(result(place: "15", team_size: 2), rules)
        assert_equal 7, Calculator.points(result(place: 2, team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "", team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: nil, team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "DNF", team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "DQ", team_size: 2), rules)
        assert_equal 0, Calculator.points(result(place: "20", team_size: 3), rules)
        assert_in_delta 0.333, Calculator.points(result(place: "15", team_size: 3), rules)
        assert_in_delta 4.666, Calculator.points(result(place: 2, team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: "", team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: nil, team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: "DNF", team_size: 3), rules)
        assert_equal 0, Calculator.points(result(place: "DQ", team_size: 3), rules)
      end

      def test_points_considers_multiplier
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ])
        assert_equal 0, Calculator.points(result(place: "7", multiplier: 0), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ])
      end

      def test_points_considers_multiplier_and_team_size
        assert_in_delta 9.333, 0.1, Calculator.points(
          result(place: "2", multiplier: 2, team_size: 3), 
          point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
        )
      end

      def test_points_considers_field_size
        assert_equal 9, Calculator.points(result(place: "7", field_size: 74), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 13.5, Calculator.points(result(place: "7", field_size: 75), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 13.5, Calculator.points(result(place: "7", field_size: 76), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
      end

      def test_points_ignore_field_size_if_multipler
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3, field_size: 74), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3, field_size: 75), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
        assert_equal 27, Calculator.points(result(place: "7", multiplier: 3, field_size: 76), point_schedule: [ 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ], field_size_bonus: true)
      end

      def test_points_use_source_result_points
        assert_equal 11, Calculator.points(
          result(place: "2", multiplier: 2, points: 11), 
          point_schedule: [ 3, 2, 1 ], 
          use_source_result_points: true
        )
      end

      def test_add_team_sizes_empty
        assert_equal [], Calculator.add_team_sizes([], {})
      end

      def test_add_team_sizes
        expected = [
          result(place: 1, race_id: 1, team_size: 2),
          result(place: 1, race_id: 1, team_size: 2),
          result(place: 2, race_id: 1, team_size: 1),
          result(place: 3, race_id: 1, team_size: 3),
          result(place: 3, race_id: 1, team_size: 3),
          result(place: 3, race_id: 1, team_size: 3),
          result(place: 1, race_id: 2, team_size: 1)
        ]
        results = [
          result(place: 1, race_id: 1),
          result(place: 1, race_id: 1),
          result(place: 2, race_id: 1),
          result(place: 3, race_id: 1),
          result(place: 3, race_id: 1),
          result(place: 3, race_id: 1),
          result(place: 1, race_id: 2)
        ]
        assert_equal expected, Calculator.add_team_sizes(results, {})
      end

      def test_map_hashes_to_results
        expected = [ Struct::CalculatorResult.new.tap { |r| r.place = 3 } ]
        actual = Calculator.map_hashes_to_results([{ place: 3 }])
        assert_equal expected, actual
      end

      def test_source_events
        source_results = [
          { event_id: 1, participant_id: 1, place: 1 },
          { event_id: 2, participant_id: 2, place: 2 }
        ]
        expected = [
          result(place: 1, participant_id: 2, points: 1, scores: [ { numeric_place: 2, participant_id: 2, points: 1 } ])
        ]
        actual = Calculator.calculate(source_results, source_event_ids: [ 2 ], members_only: false)
        assert_equal_results expected, actual
      end

      def test_ignore_empty_source_events
        source_results = [
          { event_id: 1, participant_id: 1, place: 1 },
          { event_id: 2, participant_id: 2, place: 2 }
        ]
        actual = Calculator.calculate(source_results, source_event_ids: [], members_only: false)
        assert_equal [], actual
      end
    end
  end
end