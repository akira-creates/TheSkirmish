class PoolGenerator
  def initialize(fighters, pool_size = 5)
    @fighters = fighters.shuffle
    @pool_size = pool_size
    @clubs = @fighters.group_by(&:club)
  end

  def generate
    pools = []
    pool_count = (@fighters.size.to_f / @pool_size).ceil

    # Create empty pools
    pool_count.times do |i|
      pools << Pool.create!(name: "Pool #{('A'.ord + i).chr}", status: 'active')
    end

    # Distribute fighters by club to spread them across pools
    pool_index = 0
    @clubs.each do |club, club_fighters|
      club_fighters.each do |fighter|
        pools[pool_index].fighters << fighter
        pool_index = (pool_index + 1) % pool_count
      end
    end

    # Generate matches for each pool
    pools.each(&:generate_matches)

    pools
  end
end
