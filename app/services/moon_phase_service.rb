# app/services/moon_phase_service.rb
# Serviço puro (PORO) para calcular as 4 fases principais da Lua e a estação do ano (Hemisfério Sul).
class MoonPhaseService
  # Constantes astronômicas
  SYNODIC_MONTH = 29.530588 # dias (média)
  # Referência: Lua Nova em 2000-01-06 18:14 UTC (JDN ~ 2451550.1)
  JDN_REF_NEW_MOON = 2451550.1

  # Agora trabalhamos só com 4 fases principais (0..3)
  PHASES = [
    { index: 0, name_key: "moon.phase.new_moon"      }, # Lua Nova
    { index: 1, name_key: "moon.phase.first_quarter" }, # Quarto Crescente
    { index: 2, name_key: "moon.phase.full_moon"     }, # Lua Cheia
    { index: 3, name_key: "moon.phase.last_quarter"  }  # Quarto Minguante
  ].freeze

  def initialize(date: Time.zone.now)
    @date = date.in_time_zone
  end

  def current_phase
    cache("current_phase:#{date_key}") do
      phase_index = phase_index_for(@date)
      PHASES[phase_index].slice(:index, :name_key).merge(
        start_at: phase_anchor_time(phase_index: phase_index, around: @date)
      )
    end
  end

  # Próximas n fases (sem repetir a atual), dentro do ciclo de 4
# Próximas n fases (em ordem crescente de data)
  def next_phases(n = 10)
    cache("v2:next_phases:#{date_key}:#{n}") do
      out = []
      idx = (phase_index_for(@date) + 1) % 4
      cursor = @date

      while out.size < n
        t = phase_anchor_time(phase_index: idx, around: cursor, forward: true)
        out << PHASES[idx].slice(:index, :name_key).merge(start_at: t)
        idx    = (idx + 1) % 4
        cursor = t + 1.second # garante que a próxima busca parte da última data
      end

      out
    end
  end

  # Estação atual (Hemisfério Sul – datas aproximadas por equinócios/solstícios)
  def current_season
    cache("current_season:#{date_key}") do
      season_for(@date.to_date)
    end
  end

  private

  def cache(key, &block)
    Rails.cache.fetch(key, expires_in: 1.day, &block)
  end

  def date_key
    @date.to_date.to_s
  end

  # Número do Dia Juliano (JDN) fracionário
  def jdn(time)
    t = time.utc
    y = t.year
    m = t.month
    d = t.day + (t.hour + (t.min + t.sec / 60.0) / 60.0) / 24.0

    if m <= 2
      y -= 1
      m += 12
    end

    a = (y / 100.0).floor
    b = 2 - a + (a / 4.0).floor

    (365.25 * (y + 4716)).floor + (30.6001 * (m + 1)).floor + d + b - 1524.5
  end

  # Idade da Lua em dias desde a ref. de Lua Nova
  def moon_age_days(time)
    age = (jdn(time) - JDN_REF_NEW_MOON) % SYNODIC_MONTH
    age.negative? ? age + SYNODIC_MONTH : age
  end

  # Índice de fase (0..3) mapeando por quartis do ciclo
  def phase_index_for(time)
    fraction = moon_age_days(time) / SYNODIC_MONTH
    ((fraction * 4).round) % 4
  end

  # Aproxima o instante de início da fase pedida, próximo de 'around'.
  # Com forward=true, pega a próxima ocorrência no futuro.
  def phase_anchor_time(phase_index:, around:, forward: false)
    target_fraction  = phase_index / 4.0
    current_fraction = moon_age_days(around) / SYNODIC_MONTH
    delta_days = (target_fraction - current_fraction) * SYNODIC_MONTH

    if forward
      # some 1/4 de mês até ficar estritamente no futuro
      quarter = SYNODIC_MONTH / 4.0
      delta_days += quarter while delta_days <= 0
    end

    (around + delta_days.days).utc
  end


  # Estações (Sul)
  def season_for(date)
    y = date.year
    summer_start = Date.new(y - 1, 12, 21) # verão começa no ano anterior
    autumn_start = Date.new(y, 3, 20)
    winter_start = Date.new(y, 6, 21)
    spring_start = Date.new(y, 9, 22)
    next_summer  = Date.new(y, 12, 21)

    case date
    when summer_start..(autumn_start - 1) then "season.summer"
    when autumn_start..(winter_start - 1) then "season.autumn"
    when winter_start..(spring_start - 1) then "season.winter"
    when spring_start..(next_summer - 1)  then "season.spring"
    else
      "season.summer"
    end
  end
end
