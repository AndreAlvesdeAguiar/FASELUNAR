# frozen_string_literal: true
require "httparty"
require "nokogiri"
require "cgi"

class WeatherService
  BASE = "http://servicos.cptec.inpe.br/XML"
  CACHE = Rails.cache
  DEFAULT_CITY_QUERY = "Sao Paulo"

  ICONS = {
    "ec"=>"⛅", "ci"=>"🌦️", "c"=>"☁️", "in"=>"🌫️", "pp"=>"🌧️", "cm"=>"⛅",
    "cn"=>"☁️", "pt"=>"🌩️", "pm"=>"🌧️", "np"=>"🌧️", "pc"=>"🌧️", "pn"=>"🌤️",
    "cv"=>"🌬️", "ch"=>"🌧️", "t"=>"🌩️", "ps"=>"🌦️", "e"=>"☀️", "n"=>"🌙",
    "cl"=>"🌤️", "nv"=>"🌫️", "g"=>"🌬️", "ne"=>"❄️", "nd"=>"ℹ️", "pnt"=>"🌩️",
    "psc"=>"🌦️", "pcm"=>"🌦️", "pct"=>"⛈️", "pcn"=>"🌧️", "npt"=>"🌩️", "npn"=>"🌧️",
    "ncn"=>"☁️", "nct"=>"⛈️", "ncm"=>"⛅", "npn"=>"🌧️", "pq"=>"🌫️", "np"=>"🌧️",
    "vn"=>"🌬️", "ct"=>"⛈️", "ppn"=>"🌧️", "ppt"=>"⛈️", "ppm"=>"🌧️"
  }

  LABELS = {
    "ec"=>"Encoberto com chuvas isoladas",
    "ci"=>"Chuvas isoladas",
    "c"=>"Nublado",
    "in"=>"Instável",
    "pp"=>"Possibilidade de pancadas de chuva",
    "cm"=>"Chuva pela manhã",
    "cn"=>"Nublado com chuva à noite",
    "pt"=>"Pancadas de chuva à tarde",
    "pm"=>"Pancadas de chuva pela manhã",
    "np"=>"Nublado e pancadas de chuva",
    "pc"=>"Pancadas de chuva",
    "pn"=>"Parcialmente nublado",
    "cv"=>"Chuvisco",
    "ch"=>"Chuvoso",
    "t"=>"Tempestade",
    "ps"=>"Predomínio de sol",
    "e"=>"Ensolarado",
    "n"=>"Noite limpa",
    "cl"=>"Céu claro",
    "nv"=>"Nevoeiro",
    "g"=>"Geada",
    "ne"=>"Neve"
  }

  def list_cities(query = DEFAULT_CITY_QUERY)
    key = "cptec:cities:#{query.downcase}"
    CACHE.fetch(key, expires_in: 12.hours) do
      url = "#{BASE}/listaCidades?city=#{CGI.escape(query)}"
      xml = Nokogiri::XML(HTTParty.get(url).body)
      nomes = xml.xpath("//cidade/nome").map(&:text)
      ufs   = xml.xpath("//cidade/uf").map(&:text)
      ids   = xml.xpath("//cidade/id").map { _1.text.to_i }
      nomes.zip(ufs, ids).map { |nome, uf, id| ["#{nome} #{uf}", id] }
    end
  rescue
    []
  end

  def forecast_7d(city_id)
    key = "cptec:forecast:#{city_id}"
    CACHE.fetch(key, expires_in: 2.hours) do
      url = "#{BASE}/cidade/7dias/#{city_id}/previsao.xml"
      xml = Nokogiri::XML(HTTParty.get(url).body)
      xml.xpath("//previsao").map do |dia|
        data = Date.parse(dia.at_xpath("dia").text) rescue dia.at_xpath("dia").text
        code = dia.at_xpath("tempo")&.text&.downcase
        {
          date: data,
          min: dia.at_xpath("minima")&.text&.to_i,
          max: dia.at_xpath("maxima")&.text&.to_i,
          code: code,
          icon: ICONS[code] || "ℹ️",
          label: LABELS[code] || "Condição não informada"
        }
      end
    end
  rescue
    []
  end
end
