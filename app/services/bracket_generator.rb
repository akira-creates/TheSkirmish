class BracketGenerator
  def initialize(num_qualifiers = 8)
    @num_qualifiers = num_qualifiers
    @fighters = Fighter.where(eliminated: false)
                      .order(wins: :desc, points: :desc)
                      .limit(num_qualifiers)
                      .to_a
  end

  def generate
    Bracket.destroy_all
    bracket_size = next_power_of_two(@fighters.size)
    seeded_fighters = seed_fighters(bracket_size)

    # Create winners bracket first round
    (bracket_size / 2).times do |i|
      Bracket.create!(
        round: 1,
        position: i + 1,
        bracket_type: 'winners',
        fighter1: seeded_fighters[i * 2],
        fighter2: seeded_fighters[i * 2 + 1],
        completed: false
      )
    end
    # Create placeholder losers bracket
    # This will be populated as fighters lose in winners bracket
    create_losers_bracket_structure(bracket_size)
  end

  private

  def next_power_of_two(n)
    2 ** Math.log2(n).ceil
  end

  def seed_fighters(bracket_size)
    seeded = Array.new(bracket_size)

    @fighters.each_with_index do |fighter, index|
      seeded[index] = fighter
    end

    # Standard bracket seeding (1 vs 16, 8 vs 9, etc.)
    seeded
  end

  def create_losers_bracket_structure(bracket_size)
    # Losers bracket is complex - simplified version here
    # You may want to customize this based on your tournament structure
    losers_rounds = Math.log2(bracket_size).to_i

    losers_rounds.times do |round|
      positions = 2 ** (losers_rounds - round - 1)
      positions.times do |pos|
        Bracket.create!(
          round: round + 1,
          position: pos + 1,
          bracket_type: 'losers',
          completed: false
        )
      end
    end

    # Create finals bracket
    Bracket.create!(
      round: 1,
      position: 1,
      bracket_type: 'finals',
      completed: false
    )
  end
end
