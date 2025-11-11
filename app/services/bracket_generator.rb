class BracketGenerator
  attr_reader :errors

  def initialize(num_qualifiers = 8)
    @num_qualifiers = num_qualifiers
    @errors = ActiveModel::Errors.new(self)

    if @num_qualifiers < 4
      @errors.add(:base, "Cannot generate bracket for fewer than 4 participants")
      return
    end

    unless power_of_two?(@num_qualifiers)
      @errors.add(:base, "Number of participants must be a power of 2 (4, 8, 16, 32)")
      return
    end

    @fighters = Fighter.where(eliminated: false)
                      .order(wins: :desc, points: :desc)
                      .limit(num_qualifiers)
                      .to_a

    if @fighters.size < @num_qualifiers
      @errors.add(:base, "Not enough eligible fighters (found #{@fighters.size}, need #{@num_qualifiers})")
    end
  end

  def generate
    return false if @errors.any?

    ActiveRecord::Base.transaction do
      Bracket.destroy_all

      seeded_fighters = seed_fighters(@num_qualifiers)
      create_upper_bracket(seeded_fighters)
      create_lower_bracket
      create_finals_bracket
      create_initial_matches

      true
    end
  rescue => e
    Rails.logger.error("Bracket generation failed: #{e.message}\n#{e.backtrace.join("\n")}")
    @errors.add(:base, "Generation failed: #{e.message}")
    false
  end

  private

  def power_of_two?(n)
    n > 0 && (n & (n - 1)) == 0
  end

  def seed_fighters(bracket_size)
    # Standard tournament seeding (1 vs N, 2 vs N-1, etc.)
    seeded = Array.new(bracket_size)
    fighters_by_rank = @fighters.dup

    # Fill seeded array with proper tournament seeding
    i = 0
    j = bracket_size - 1
    k = 0

    while i <= j
      seeded[k] = fighters_by_rank[i] if i < fighters_by_rank.size
      k += 1
      seeded[k] = fighters_by_rank[j] if j < fighters_by_rank.size && i != j
      k += 1
      i += 1
      j -= 1
    end

    seeded
  end

  def create_upper_bracket(seeded_fighters)
    num_rounds = Math.log2(@num_qualifiers).to_i
    current_fighters = seeded_fighters

    num_rounds.times do |round_index|
      round = round_index + 1
      num_matches = current_fighters.size / 2

      num_matches.times do |match_index|
        Bracket.create!(
          round: round,
          position: match_index + 1,
          bracket_type: 'upper',
          fighter1: current_fighters[match_index * 2],
          fighter2: current_fighters[match_index * 2 + 1],
          completed: false
        )
      end

      # For next round, we'll have half the fighters (set to nil as they advance)
      current_fighters = Array.new(num_matches, nil)
    end
  end

  def create_lower_bracket
    num_upper_rounds = Math.log2(@num_qualifiers).to_i
    num_lower_rounds = (num_upper_rounds * 2) - 2

    num_lower_rounds.times do |round_index|
      round = round_index + 1
      num_matches = calculate_lower_bracket_matches(round, @num_qualifiers)

      num_matches.times do |match_index|
        Bracket.create!(
          round: round,
          position: match_index + 1,
          bracket_type: 'lower',
          fighter1: nil,
          fighter2: nil,
          completed: false
        )
      end
    end
  end

  def calculate_lower_bracket_matches(round, bracket_size)
    # Lower bracket structure for double elimination:
    # Round 1: Losers from UB R1 pair up → bracket_size / 4 matches
    # Round 2: Winners from LB R1 advance → bracket_size / 8 matches
    # Round 3: Winners from LB R2 meet losers from UB R2 → bracket_size / 8 matches
    # Round 4: Winners from LB R3 advance → bracket_size / 16 matches
    # Pattern: Each pair of rounds halves the matches

    round_pair = ((round - 1) / 2) + 1
    bracket_size / (2 ** (round_pair + 1))
  end

  def create_finals_bracket
    Bracket.create!(
      round: 1,
      position: 1,
      bracket_type: 'finals',
      fighter1: nil,
      fighter2: nil,
      completed: false
    )
  end

  def create_initial_matches
    # Create matches for all Round 1 upper bracket matches that have both fighters
    Bracket.where(bracket_type: 'upper', round: 1).find_each do |bracket|
      bracket.create_match if bracket.ready_to_fight?
    end
  end
end
