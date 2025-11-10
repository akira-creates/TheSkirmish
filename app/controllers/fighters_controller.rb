class FightersController < ApplicationController
  before_action :set_fighter, only: [ :show, :edit, :update, :destroy ]

  def index
    @fighters = Fighter.order(:club, :name)
  end

  def show
    @matches = @fighter.all_matches.includes(:fighter1, :fighter2, :winner)
  end

  def new
    @fighter = Fighter.new
  end

  def create
    @fighter = Fighter.new(fighter_params)

    if @fighter.save
      redirect_to fighters_path, notice: 'Fighter registered successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @all_fighters = Fighter.order(:name)
  end

  def update
    if @fighter.update(fighter_params)
      redirect_to fighters_path, notice: 'Fighter updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fighter.destroy
    redirect_to fighters_path, notice: 'Fighter removed successfully.'
  end

  private

  def set_fighter
    @fighter = Fighter.find(params[:id])
  end

  def fighter_params
    params.require(:fighter).permit(:name, :club)
  end
end
