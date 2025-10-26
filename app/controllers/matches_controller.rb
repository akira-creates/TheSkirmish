class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :setup, :edit, :update, :record_result]

  def index
    @pending_matches = Match.where(status: 'pending')
                           .includes(:fighter1, :fighter2, :pool)
    @completed_matches = Match.where(status: 'completed')
                             .includes(:fighter1, :fighter2, :winner, :pool)
                             .order(updated_at: :desc)
                             .limit(20)
  end

  def show
  end

  def setup
    @main_weapons = Weapon.main_hand.order(:name)
    @off_weapons = Weapon.off_hand.order(:name)
  end

  def update
    if @match.update(weapon_params)
      redirect_to edit_match_path(@match), notice: 'Weapons selected. Ready to score match.'
    else
      @main_weapons = Weapon.main_hand.order(:name)
      @off_weapons = Weapon.off_hand.order(:name)
      render :setup, status: :unprocessable_entity
    end
  end

  def edit
    unless @match.weapons_selected?
      redirect_to setup_match_path(@match), alert: 'Please select weapons first.'
    end
  end

  def record_result
    winner_id = params[:winner_id]
    f1_points = params[:fighter1_points].to_i
    f2_points = params[:fighter2_points].to_i
    duration = params[:duration].to_i

    @match.complete_match(winner_id, f1_points, f2_points, duration)
    redirect_to matches_path, notice: 'Match result recorded successfully.'
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def weapon_params
    params.require(:match).permit(
      :fighter1_main_id, :fighter1_offhand_id, :fighter1_debuff,
      :fighter2_main_id, :fighter2_offhand_id, :fighter2_debuff
    )
  end
end
