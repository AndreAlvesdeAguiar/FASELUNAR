class WeatherController < ApplicationController
  def index
    @cidades = listaCidades
  end

  def listaCidades
    url = "http://servicos.cptec.inpe.br/XML/listaCidades?city="
    response = HTTParty.get(url)

    xml = Nokogiri::XML(response.body)
    nomes = xml.xpath('//nome').map(&:text)
    ufs = xml.xpath('//uf').map(&:text)
    ids = xml.xpath('//id').map { |node| node.text.to_i }

    @data = nomes.zip(ufs, ids)
  end

  def previsao
    cidade_id = params[:cidade_id]
    url = "http://servicos.cptec.inpe.br/XML/cidade/7dias/#{cidade_id}/previsao.xml"
    response = HTTParty.get(url)
  
    xml = Nokogiri::XML(response.body)
    @previsao = parse_xml_previsao(xml)
  
    if @previsao.nil?
      flash.now[:error] = "Não foi possível obter a previsão. Tente novamente mais tarde."
    end
  
    @cidades = listaCidades
  
    render "index"
  end
  

  private

  def parse_xml_previsao(xml)
    previsao = []

    dias = xml.xpath('//previsao')

    dias.each do |dia|
      data = dia.xpath('dia').text
      maxima = dia.xpath('maxima').text
      minima = dia.xpath('minima').text

      previsao << {
        data: data,
        maxima: maxima,
        minima: minima
      }
    end

    previsao
  end
end
