class Esp32Controller < ApplicationController
    include ActionController::Live
  
    def index
      # Realiza a consulta inicial à API e obtém os dados
      @dados1 = fetchSensorData("http://192.168.15.12/data")
      @dados2 = fetchSensorData("http://192.168.15.13/data")
    end
  
    private
  
    def fetchSensorData(url)
      response = HTTParty.get(url)
      response.parsed_response
    end
  end
  