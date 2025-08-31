class HomeController < ApplicationController
  def index
    m = MoonService.new
    @current_phase  = m.current_phase
    @next_phases    = m.next_phases(12)
    @current_season = m.current_season

    weather = WeatherService.new
    sp = weather.list_cities("Sao Paulo")
    sp_id = sp.first&.last
    @forecast = sp_id ? weather.forecast_7d(sp_id) : []
    @today = @forecast.first
    @city_label = "São Paulo"
  end
end
