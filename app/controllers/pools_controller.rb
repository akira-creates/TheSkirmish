class PoolsController < ApplicationController
  before_action :set_pool, only: [ :show, :edit, :update, :destroy, :generate_matches, :clear_matches, :complete ]

  def index
    @pools = Pool.includes(:fighters).order(:name)
  end

  def show
    @matches = @pool.matches.includes(:fighter1, :fighter2, :winner)
                    .order(created_at: :asc)
  end

  def new
    if Fighter.count == 0
      redirect_to fighters_path, alert: 'Please register fighters first.'
      return
    end

    @pool_size = params[:pool_size]&.to_i || 5
  end

  def create
    pool_size = params[:pool_size]&.to_i || 5
    fighters = Fighter.where(eliminated: false)

    generator = PoolGenerator.new(fighters, pool_size)
    @pools = generator.generate

    redirect_to pools_path, notice: "#{@pools.count} pools created successfully."
  end

  def edit
    @available_fighters = Fighter.where(eliminated: false)
                                 .where.not(id: @pool.fighters.pluck(:id))
  end

  def update
    if params[:fighter_ids]
      @pool.pool_fighters.destroy_all
      params[:fighter_ids].each_with_index do |fighter_id, index|
        next if fighter_id.blank?
        PoolFighter.create!(
          pool: @pool,
          fighter_id: fighter_id,
          position: index + 1
        )
      end
      @pool.generate_matches
      redirect_to @pool, notice: 'Pool updated and matches regenerated.'
    elsif @pool.update(pool_params)
      redirect_to @pool, notice: 'Pool updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pool.destroy
    redirect_to pools_path, notice: 'Pool deleted successfully.'
  end

  def generate_matches
    @pool.generate_matches
    redirect_to @pool, notice: 'Matches generated successfully.'
  end

  def clear_matches
    @pool.matches.destroy_all
    redirect_to @pool, notice: 'All matches cleared successfully.'
  end

  def complete
    if @pool.all_matches_completed?
      @pool.complete_pool
      redirect_to pools_path, notice: 'Pool completed and standings calculated.'
    else
      redirect_to @pool, alert: 'All matches must be completed first.'
    end
  end

  private

  def set_pool
    @pool = Pool.find(params[:id])
  end

  def pool_params
    params.require(:pool).permit(:name, :pool_size)
  end
end
