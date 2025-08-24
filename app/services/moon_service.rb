# frozen_string_literal: true

class MoonService
  SYNODIC_MONTH = 29.53058867
  EPOCH_JD = 2451550.1 # 2000-01-06 18:14 UTC nova-lua

  PHASES_PT = [
    "Lua Nova",
    "Lua Crescente",
    "Quarto Crescente",
    "Gibosa Crescente",
    "Lua Cheia",
    "Gibosa Minguante",
    "Quarto Minguante",
    "Lua Minguante"
  ].freeze

  def current_phase(date = Date.today)
    age = moon_age(date)
    { phase: phase_name_by_age(age) }
  end

  def next_phases(days = 30, start_date = Date.today)
    date = start_date
    out = []
    days.times do
      age = moon_age(date)
      out << { date: date, phase: phase_name_by_age(age) }
      date += 1
    end
    out
  end

  def current_season(today = Date.today)
    seasons = {
      verão:     { start_date: Date.new(today.year, 12, 21), end_date: Date.new(today.year + 1, 3, 20) },
      outono:    { start_date: Date.new(today.year, 3, 21),  end_date: Date.new(today.year, 6, 20) },
      inverno:   { start_date: Date.new(today.year, 6, 21),  end_date: Date.new(today.year, 9, 22) },
      primavera: { start_date: Date.new(today.year, 9, 23),  end_date: Date.new(today.year, 12, 20) }
    }

    season = seasons.detect do |_, dates|
      start_y = yday(dates[:start_date])
      end_y   = yday(dates[:end_date])
      ty      = yday(today)
      start_y <= end_y ? (start_y..end_y).cover?(ty) : ((start_y..366).cover?(ty) || (1..end_y).cover?(ty))
    end

    {
      name: season&.first&.to_s&.capitalize,
      start_date: season&.last&.fetch(:start_date),
      end_date: season&.last&.fetch(:end_date)
    }
  end

  private

  def moon_age(date)
    # usa meio-dia local para reduzir erro inteiro do JD
    dt = DateTime.new(date.year, date.month, date.day, 12, 0, 0)
    jd = dt.ajd.to_f * 2 # ajd é em dias julianos com origem 0. Ajuste padrão do Ruby
    age = (jd - EPOCH_JD) % SYNODIC_MONTH
    age < 0 ? age + SYNODIC_MONTH : age
  end

  def phase_name_by_age(age)
    f = age / SYNODIC_MONTH
    case f
    when 0...0.0625 then PHASES_PT[0]               # Lua Nova
    when 0.0625...0.1875 then PHASES_PT[1]          # Lua Crescente
    when 0.1875...0.3125 then PHASES_PT[2]          # Quarto Crescente
    when 0.3125...0.4375 then PHASES_PT[3]          # Gibosa Crescente
    when 0.4375...0.5625 then PHASES_PT[4]          # Lua Cheia
    when 0.5625...0.6875 then PHASES_PT[5]          # Gibosa Minguante
    when 0.6875...0.8125 then PHASES_PT[6]          # Quarto Minguante
    when 0.8125...0.9375 then PHASES_PT[7]          # Lua Minguante
    else PHASES_PT[0]
    end
  end

  def yday(d)
    d.yday == 366 ? 365 : d.yday
  end
end
