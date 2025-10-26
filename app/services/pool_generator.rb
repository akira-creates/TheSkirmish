class PoolGenerator
  def initialize(fighters, pool_size = 5)
    @fighters = fighters.shuffle
    @pool_size = pool_size
    @clubs = @fighters.group_by(&:club)
  end

  def generate
    pools = []
    pool_count = (@fighters.size.to_f / @pool_size).ceil

    # Delete existing pools
    Pool.destroy_all

    # Create empty pools
    pool_count.times do |i|
      pools << Pool.create!(
        name: "Pool #{('A'.ord + i).chr}", 
        status: 'active',
        pool_size: @pool_size
      )
    end

    # Distribute fighters by club to spread them across pools
    pool_index = 0
    @clubs.each do |club, club_fighters|
      club_fighters.shuffle.each do |fighter|
        PoolFighter.create!(
          pool: pools[pool_index],
          fighter: fighter,
          position: pools[pool_index].fighters.count + 1
        )
        pool_index = (pool_index + 1) % pool_count
      end
    end

    # Generate matches for each pool
    pools.each(&:generate_matches)

    pools
  end
end
