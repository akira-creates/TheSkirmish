class BracketsController < ApplicationController
  before_action :set_bracket, only: [ :show, :edit, :update, :record_result ]

  def index
    @winners_brackets = Bracket.winners_bracket.includes(:fighter1, :fighter2, :winner, :match).order(:round, :position)
    @losers_brackets = Bracket.losers_bracket.includes(:fighter1, :fighter2, :winner, :match).order(:round, :position)
    @finals = Bracket.finals.includes(:fighter1, :fighter2, :winner, :match).first
  end

  def new
    unless Pool.where(completed: true).count == Pool.count && Pool.count > 0
      redirect_to pools_path, alert: 'Please complete all pools first.'
      return
    end
    # Use the new private method to load data
    load_new_page_data
  end

  def create
    @num_qualifiers = params[:num_qualifiers]&.to_i || 8
    generator = BracketGenerator.new(@num_qualifiers)

    begin
      # --- REFACTOR ---
      # Assume .generate returns true on success and false on failure
      # (e.g., not enough fighters, not a power of 2, etc.)
      if generator.generate
        notice = "Brackets created with top #{@num_qualifiers} fighters."
        respond_to do |format|
          format.html { redirect_to brackets_path, notice: notice }
          # Redirecting within a turbo_stream response is fine,
          # Turbo will follow it with a 'visit'.
          format.turbo_stream { redirect_to brackets_path, notice: notice }
        end
      else
        # Generation failed (returned false or nil)
        handle_generation_failure(generator.errors.full_messages.join(', ') || "Failed to generate brackets. Not enough fighters?")
      end
    rescue => e
      # --- REFACTOR ---
      # Handle any exceptions raised during generation
      Rails.logger.error "Bracket generation failed: #{e.message}\n#{e.backtrace.join("\n")}"
      handle_generation_failure("An unexpected error occurred: #{e.message}")
    end
  end

  def show
  end

  def edit
    @available_fighters = Fighter.where(eliminated: false)
                                .where.not(id: [ @bracket.fighter1_id, @bracket.fighter2_id ].compact)
  end

  def update
    if params[:reassign]
      if @bracket.update(bracket_params)
        # Recreate match if both fighters are assigned
        if @bracket.fighter1_id.present? && @bracket.fighter2_id.present?
          @bracket.match&.destroy
          @bracket.create_match
        end
        redirect_to brackets_path, notice: 'Bracket fighters updated.'
      else
        @available_fighters = Fighter.where(eliminated: false)
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def record_result
    winner_id = params[:winner_id]
    @bracket.complete_bracket(winner_id)

    redirect_to brackets_path, notice: 'Bracket result recorded.'
  end

  def generate_matches
    brackets = Bracket.where(completed: false)
    generated = 0

    brackets.each do |bracket|
      if bracket.ready_to_fight? && bracket.match.nil?
        bracket.create_match
        generated += 1
      end
    end

    redirect_to brackets_path, notice: "Generated #{generated} bracket matches."
  end

  private

  # --- NEW PRIVATE METHOD ---
  # Loads data needed for the 'new' template.
  # This allows 'create' to re-use it when re-rendering 'new' on error.
  def load_new_page_data
    @num_qualifiers ||= params[:num_qualifiers]&.to_i || 8
    @top_fighters = Fighter.where(eliminated: false)
                          .order(wins: :desc, points: :desc)
                          .limit(@num_qualifiers)
  end

  # --- NEW PRIVATE METHOD ---
  # Handles the response for a failed generation attempt.
  def handle_generation_failure(error_message)
    load_new_page_data
    flash.now[:alert] = error_message

    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      # For Turbo Stream, you might want to replace a specific part of the page
      # (like a form or an error container) instead of just rendering 'new'.
      # For simplicity here, we'll just render the 'new' status,
      # but a better implementation would use a .turbo_stream.erb file
      # or turbo_stream.replace/update.
      format.turbo_stream {
        render :new, status: :unprocessable_entity
        # A more Turbo-native way would be:
        # render turbo_stream: turbo_stream.replace("new_bracket_form", # or some error div
        #                                          partial: "form",
        #                                          locals: { errors: [error_message], ... })
      }
    end
  end

  def set_bracket
    @bracket = Bracket.find(params[:id])
  end

  def bracket_params
    params.require(:bracket).permit(:fighter1_id, :fighter2_id)
  end
end
