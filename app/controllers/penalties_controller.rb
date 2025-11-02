class PenaltiesController < ApplicationController
  before_action :set_match
  before_action :set_penalty, only: [ :destroy ]

  def create
    @penalty = @match.penalties.build(penalty_params)
    @penalty.issued_at = Time.current

    if @penalty.save
      # Handle black card - eliminate fighter
      if @penalty.card_type == 'black'
        @penalty.fighter.update(eliminated: true)
      end

      redirect_to edit_match_path(@match), notice: "#{@penalty.display_name} issued to #{@penalty.fighter.name}"
    else
      redirect_to edit_match_path(@match), alert: 'Failed to issue penalty'
    end
  end

  def destroy
    fighter_name = @penalty.fighter.name
    @penalty.destroy
    redirect_to edit_match_path(@match), notice: "Penalty removed from #{fighter_name}"
  end

  private

  def set_match
    @match = Match.find(params[:match_id])
  end

  def set_penalty
    @penalty = Penalty.find(params[:id])
  end

  def penalty_params
    params.require(:penalty).permit(:fighter_id, :card_type, :reason)
  end
end
