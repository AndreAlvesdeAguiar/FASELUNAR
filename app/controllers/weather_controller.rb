class WeatherController < ApplicationController
  def index
    listaCidades
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
end
