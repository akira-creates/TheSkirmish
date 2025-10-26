class BracketGenerator
  def initialize(fighters)
    @fighters = fighters.sort_by { |f| [-f.wins, -f.points] }
  end

  def generate
    # Ensure power of 2 for bracket size
    bracket_size = next_power_of_two(@fighters.size)

    # Seed fighters
    seeded_fighters = seed_fighters(bracket_size)

    # Create first round brackets
    (bracket_size / 2).times do |i|
      Bracket.create!(
        round: 1,
        position: i + 1,
        fighter1: seeded_fighters[i * 2],
        fighter2: seeded_fighters[i * 2 + 1]
      )
    end
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
end
