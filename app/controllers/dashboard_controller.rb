class DashboardController < ApplicationController
  def index
    @fighters_count = Fighter.count
    @pools_count = Pool.count
    @active_pools = Pool.where(completed: false).count
    @brackets_count = Bracket.count
    @pending_matches = Match.where(status: 'pending').count
  end
end
