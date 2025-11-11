class TournamentController < ApplicationController
  def summary
    # Top 3 fighters (podium) - includes all matches (pools + brackets)
    @top_fighters = Fighter.where.not(wins: 0, losses: 0)
                          .order(wins: :desc, points: :desc, points_against: :asc)
                          .limit(3)

    # Champion from finals
    @champion = Bracket.finals.completed.first&.winner

    # Most points scored by a single fighter across all their matches
    completed_matches = Match.where(status: 'completed')
    @most_total_points_fighter = Fighter.where.not(points: 0)
                                       .order(points: :desc)
                                       .first

    # Most points scored by a single fighter in a match
    @most_points_single_fighter = completed_matches.flat_map do |m|
      [
        { fighter: m.fighter1, points: m.fighter1_points, match: m },
        { fighter: m.fighter2, points: m.fighter2_points, match: m }
      ]
    end.max_by { |h| h[:points] || 0 }

    # Most used weapons
    weapon_usage = {}
    completed_matches.each do |match|
      [ match.fighter1_main, match.fighter1_offhand, match.fighter2_main, match.fighter2_offhand ].each do |weapon|
        next unless weapon
        weapon_usage[weapon] ||= 0
        weapon_usage[weapon] += 1
      end
    end
    @most_used_weapons = weapon_usage.sort_by { |_, count| -count }.first(5)

    # Most used debuffs
    debuff_usage = Hash.new(0)
    completed_matches.each do |match|
      debuff_usage[match.fighter1_debuff] += 1 if match.fighter1_debuff.present? && match.fighter1_debuff != 'None'
      debuff_usage[match.fighter2_debuff] += 1 if match.fighter2_debuff.present? && match.fighter2_debuff != 'None'
    end
    @most_used_debuffs = debuff_usage.sort_by { |_, count| -count }.first(5)

    # Weapon win rates
    weapon_stats = calculate_weapon_win_rates(completed_matches)
    @highest_winrate_weapons = weapon_stats.select { |_, data| data[:uses] >= 3 }
                                           .sort_by { |_, data| -data[:win_rate] }
                                           .first(5)
    @lowest_winrate_weapons = weapon_stats.select { |_, data| data[:uses] >= 3 }
                                          .sort_by { |_, data| data[:win_rate] }
                                          .first(5)

    # Shortest match
    @shortest_match = completed_matches.where.not(duration: nil).min_by(&:duration)

    # Most successful weapon combos (main + offhand)
    weapon_combo_stats = calculate_weapon_combo_stats(completed_matches)
    @most_successful_weapon_combos = weapon_combo_stats.select { |_, data| data[:uses] >= 2 }
                                                       .sort_by { |_, data| [ -data[:win_rate], -data[:wins] ] }
                                                       .first(5)

    # Most successful overall combos (main + offhand + debuff)
    overall_combo_stats = calculate_overall_combo_stats(completed_matches)
    @most_successful_overall_combos = overall_combo_stats.select { |_, data| data[:uses] >= 2 }
                                                         .sort_by { |_, data| [ -data[:win_rate], -data[:wins] ] }
                                                         .first(5)

    # Total stats
    @total_matches = completed_matches.count
    @total_points_scored = completed_matches.sum { |m| (m.fighter1_points || 0) + (m.fighter2_points || 0) }
    @average_match_duration = completed_matches.where.not(duration: nil).average(:duration)&.to_f || 0
  end

  private

  def calculate_weapon_win_rates(matches)
    weapon_stats = Hash.new { |h, k| h[k] = { wins: 0, uses: 0, win_rate: 0.0 } }

    matches.each do |match|
      next unless match.winner_id

      # Fighter 1's weapons
      [ match.fighter1_main, match.fighter1_offhand ].compact.each do |weapon|
        weapon_stats[weapon][:uses] += 1
        weapon_stats[weapon][:wins] += 1 if match.winner_id == match.fighter1_id
      end

      # Fighter 2's weapons
      [ match.fighter2_main, match.fighter2_offhand ].compact.each do |weapon|
        weapon_stats[weapon][:uses] += 1
        weapon_stats[weapon][:wins] += 1 if match.winner_id == match.fighter2_id
      end
    end

    # Calculate win rates
    weapon_stats.each do |weapon, stats|
      stats[:win_rate] = stats[:uses] > 0 ? (stats[:wins].to_f / stats[:uses] * 100) : 0
    end

    weapon_stats
  end

  def calculate_weapon_combo_stats(matches)
    combo_stats = Hash.new { |h, k| h[k] = { wins: 0, uses: 0, win_rate: 0.0 } }

    matches.each do |match|
      next unless match.winner_id

      # Fighter 1's combo
      if match.fighter1_main
        combo = {
          main: match.fighter1_main,
          offhand: match.fighter1_offhand
        }
        combo_stats[combo][:uses] += 1
        combo_stats[combo][:wins] += 1 if match.winner_id == match.fighter1_id
      end

      # Fighter 2's combo
      if match.fighter2_main
        combo = {
          main: match.fighter2_main,
          offhand: match.fighter2_offhand
        }
        combo_stats[combo][:uses] += 1
        combo_stats[combo][:wins] += 1 if match.winner_id == match.fighter2_id
      end
    end

    # Calculate win rates
    combo_stats.each do |combo, stats|
      stats[:win_rate] = stats[:uses] > 0 ? (stats[:wins].to_f / stats[:uses] * 100) : 0
    end

    combo_stats
  end

  def calculate_overall_combo_stats(matches)
    combo_stats = Hash.new { |h, k| h[k] = { wins: 0, uses: 0, win_rate: 0.0 } }

    matches.each do |match|
      next unless match.winner_id

      # Fighter 1's full combo
      if match.fighter1_main
        combo = {
          main: match.fighter1_main,
          offhand: match.fighter1_offhand,
          debuff: match.fighter1_debuff
        }
        combo_stats[combo][:uses] += 1
        combo_stats[combo][:wins] += 1 if match.winner_id == match.fighter1_id
      end

      # Fighter 2's full combo
      if match.fighter2_main
        combo = {
          main: match.fighter2_main,
          offhand: match.fighter2_offhand,
          debuff: match.fighter2_debuff
        }
        combo_stats[combo][:uses] += 1
        combo_stats[combo][:wins] += 1 if match.winner_id == match.fighter2_id
      end
    end

    # Calculate win rates
    combo_stats.each do |combo, stats|
      stats[:win_rate] = stats[:uses] > 0 ? (stats[:wins].to_f / stats[:uses] * 100) : 0
    end

    combo_stats
  end
end
