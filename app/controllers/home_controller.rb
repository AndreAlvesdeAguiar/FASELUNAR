class HomeController < ApplicationController
  def index
    m = MoonService.new
    @current_phase  = m.current_phase
    @next_phases    = m.next_phases(30)
    @current_season = m.current_season
  end
end
