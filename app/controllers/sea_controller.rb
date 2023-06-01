class SeaController < ApplicationController

    def index
        url = "https://api.ipma.pt/open-data/forecast/oceanography/daily/hp-daily-sea-forecast-day0.json"
        response = HTTParty.get(url)
        @sea = response.parsed_response
    end
end

#https://api.ipma.pt/#ipma