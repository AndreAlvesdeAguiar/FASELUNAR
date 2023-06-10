class Esp32Controller < ApplicationController
    include ActionController::Live
  
    def index
      # Realiza a consulta inicial à API e obtém os dados
      @dados1 = fetchSensorData("http://192.168.15.12/data")
      @dados2 = fetchSensorData("http://192.168.15.13/data")
    end
  
    def stream
      response.headers['Content-Type'] = 'text/event-stream'
      10.times do
        # Obtém os dados atualizados a cada iteração
        @dados1 = fetchSensorData("http://192.168.15.12/data")
        @dados2 = fetchSensorData("http://192.168.15.13/data")
  
        # Renderiza a página index.html.erb como uma string
        rendered_html = render_to_string(template: 'esp32/index', layout: false)
  
        # Envia os dados atualizados para o cliente
        response.stream.write("data: #{rendered_html}\n\n")
  
        sleep 1
      end
    ensure
      response.stream.close
    end
  
    private
  
    def fetchSensorData(url)
      response = HTTParty.get(url)
      response.parsed_response
    end
  end
  