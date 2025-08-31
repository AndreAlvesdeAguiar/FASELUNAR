# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    svc = MoonPhaseService.new(date: Time.zone.now)

    cur = svc.current_phase
    nxt = svc.next_phases(4)

    @current_phase = {
      phase: I18n.t(cur[:name_key]),
      date:  cur[:start_at].in_time_zone.to_date
    }

    @next_phases = nxt.map do |p|
      {
        date:  p[:start_at].in_time_zone.to_date,
        phase: I18n.t(p[:name_key])
      }
    end

    # estação (name + datas aproximadas do período)
    season_key = svc.current_season
    @current_season = season_bounds_for(season_key).merge(name: I18n.t(season_key))

    # ---------------- CLIMA (CPTEC/INPE) ----------------
    # Pode sobrescrever via ENV:
    #   CITY_LABEL="Campinas, SP"
    #   CITY_ID=244
    label_env = ENV["CITY_LABEL"].presence
    id_env    = ENV["CITY_ID"].presence&.to_i

    service = WeatherService.new

    if id_env
      city_id    = id_env
      @city_label = label_env || "São Paulo, SP"
    else
      # tenta encontrar a cidade por nome (padrão: São Paulo)
      desired_label = label_env || "São Paulo, SP"
      query = desired_label.split(",").first # "São Paulo"

      cities = service.list_cities(query) # => [["São Paulo SP", 244], ...]
      match  = pick_city(cities, desired_label) || cities.first

      @city_label = (match&.first || desired_label)
      city_id     = (match&.last  || 244) # 244 é SP capital no CPTEC
    end

    forecast = service.forecast_7d(city_id) # array de hashes
    today    = forecast.find { |d| d[:date].is_a?(Date) ? d[:date] == Date.today : false } || forecast.first

    @today = if today
      { max: today[:max], min: today[:min], icon: today[:icon], label: today[:label], date: today[:date] }
    else
      { max: nil, min: nil, icon: nil, label: nil, date: Date.today }
    end
    # ----------------------------------------------------
  end

  private

  # Datas aproximadas do intervalo de cada estação (Hemisfério Sul)
  def season_bounds_for(season_key)
    today = Time.zone.today
    y = today.year
    case season_key
    when "season.summer" then { start_date: Date.new(y - 1, 12, 21), end_date: Date.new(y, 3, 19) }
    when "season.autumn" then { start_date: Date.new(y, 3, 20),     end_date: Date.new(y, 6, 20) }
    when "season.winter" then { start_date: Date.new(y, 6, 21),     end_date: Date.new(y, 9, 21) }
    when "season.spring" then { start_date: Date.new(y, 9, 22),     end_date: Date.new(y, 12, 20) }
    else                       { start_date: nil,                    end_date: nil }
    end
  end

  # cities: [["São Paulo SP", 244], ...]
  # desired_label: "São Paulo, SP"
  def pick_city(cities, desired_label)
    return nil if cities.blank?

    desired_name = desired_label.split(",").first.to_s.strip # "São Paulo"
    desired_uf   = desired_label.split(",")[1].to_s.strip.upcase # "SP"

    # normaliza sem acentos, case-insensitive
    normalize = ->(s) { I18n.transliterate(s.to_s).downcase }

    exact = cities.find do |label, _id|
      parts = label.to_s.split(" ")
      uf = parts.last.to_s.upcase
      name = normalize.call(parts[0..-2].join(" "))
      name == normalize.call(desired_name) && (desired_uf.blank? || uf == desired_uf)
    end
    return exact if exact

    # fallback: começa com o nome desejado
    cities.find { |label, _id| normalize.call(label).start_with?(normalize.call(desired_name)) }
  end
end
