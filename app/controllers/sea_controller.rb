class SeaController < ApplicationController
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
  
    def previsao2
      cidade_id = params[:cidade_id]
      url = "http://servicos.cptec.inpe.br/XML/cidade/#{cidade_id}/dia/0/ondas.xml"
      response = HTTParty.get(url)
  
      xml = Nokogiri::XML(response.body)
      @previsao2 = parse_xml_previsao(xml)
  
      if @previsao2.nil?
        flash.now[:error] = "Não foi possível obter a previsão. Tente novamente mais tarde."
      end
  
      @cidades = listaCidades
  
      render "index"
    end
  
    def parse_xml_previsao(xml)
        previsao = []
      
        manha = xml.at_xpath('//manha')
        if manha
          dia = manha.at_xpath('dia')&.text
          agitacao = manha.at_xpath('agitacao')&.text
          altura = manha.at_xpath('altura')&.text
          direcao = manha.at_xpath('direcao')&.text
          vento = manha.at_xpath('vento')&.text
          vento_dir = manha.at_xpath('vento_dir')&.text
      
          previsao << {
            dia: dia,
            agitacao: agitacao,
            altura: altura,
            direcao: direcao,
            vento: vento,
            vento_dir: vento_dir
          }
        end
      
        previsao
      end
      
  end
  