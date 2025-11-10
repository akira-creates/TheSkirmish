class BracketsController < ApplicationController
  before_action :set_bracket, only: [:edit, :update, :record_result]

  def index
    @upper_brackets = Bracket.upper_bracket.includes(:fighter1, :fighter2, :winner, :match).order(:round, :position)
    @lower_brackets = Bracket.lower_bracket.includes(:fighter1, :fighter2, :winner, :match).order(:round, :position)
    @finals = Bracket.finals.includes(:fighter1, :fighter2, :winner, :match).first
  end

  def new
    unless Pool.where(completed: true).count == Pool.count && Pool.count > 0
      redirect_to pools_path, alert: 'Please complete all pools first.'
      return
    end

    @num_qualifiers = params[:num_qualifiers]&.to_i || 8
    @top_fighters = Fighter.where(eliminated: false)
                          .order(wins: :desc, points: :desc)
                          .limit(@num_qualifiers)
  end

  def create
    @num_qualifiers = params[:num_qualifiers]&.to_i || 8
    generator = BracketGenerator.new(@num_qualifiers)

    if generator.generate
      redirect_to brackets_path, notice: "Brackets created with #{@num_qualifiers} fighters."
    else
      @top_fighters = Fighter.where(eliminated: false)
                            .order(wins: :desc, points: :desc)
                            .limit(@num_qualifiers)
      flash.now[:alert] = generator.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @all_fighters = Fighter.order(:name)
  end

  def update
    if @bracket.update(bracket_params)
      if @bracket.fighter1_id.present? && @bracket.fighter2_id.present?
        @bracket.match&.destroy
        @bracket.create_match
      end
      redirect_to brackets_path, notice: 'Bracket updated successfully.'
    else
      @all_fighters = Fighter.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def record_result
    winner_id = params[:winner_id]
    @bracket.complete_bracket(winner_id)
    redirect_to brackets_path, notice: 'Bracket result recorded.'
  end

  def generate_matches
    generated = 0
    Bracket.where(completed: false).find_each do |bracket|
      if bracket.ready_to_fight? && bracket.match.nil?
        bracket.create_match
        generated += 1
      end
    end

    redirect_to brackets_path, notice: "Generated #{generated} matches."
  end

  private

  def set_bracket
    @bracket = Bracket.find(params[:id])
  end

  def bracket_params
    params.require(:bracket).permit(:fighter1_id, :fighter2_id)
  end
end
