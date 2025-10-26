class BracketsController < ApplicationController
  before_action :set_bracket, only: [:show, :edit, :record_result]

  def index
    @winners_brackets = Bracket.winners_bracket.order(:round, :position)
    @losers_brackets = Bracket.losers_bracket.order(:round, :position)
    @finals = Bracket.finals.first
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
    num_qualifiers = params[:num_qualifiers]&.to_i || 8
    generator = BracketGenerator.new(num_qualifiers)
    generator.generate

    redirect_to brackets_path, notice: "Bracket created with top #{num_qualifiers} fighters."
  end

  def show
  end

  def edit
  end

  def record_result
    winner_id = params[:winner_id]
    @bracket.complete_bracket(winner_id)

    redirect_to brackets_path, notice: 'Bracket result recorded.'
  end

  private

  def set_bracket
    @bracket = Bracket.find(params[:id])
  end
end
