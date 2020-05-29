require 'ostruct'
require "f1sales_custom/parser"
require "f1sales_custom/source"

RSpec.describe F1SalesCustom::Email::Parser do

  context 'when is a different template' do
    let(:email){
      email = OpenStruct.new
      email.to = [email: 'website@abhdrj.f1sales.net'],
      email.subject = 'Lead: Cliente interessado em veiculo novo',
      email.body = "Fat Bob\n\nUm cliente interssado em um veículo enviou os seguintes dados:\n\nO link para o veículo é:\nhttps://www.grupoab.com.br/harley-davidson/bh-harley/novos/fat-bob/\n\nNome\n\nTIAGO JEREMIAS DOS ANJOS\n\nE-mail\n\ntjanjosmed@hotmail.com\n\nTelefone\n\n31-99362-4989\n\nDeseja contato por\n\ntelefone\n\nMensagem\n\nOlá, gostaria de mais informações e condições para compra.\n\nNewsletter\n\nData\n\n2020-05-21 11:37:12\n\nVeículo escolhido\n\nmodelo\n\nFat Bob\n\nmarca\n\nHarley-Davidson"

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq(F1SalesCustom::Email::Source.all[0][:name])
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('TIAGO JEREMIAS DOS ANJOS')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('tjanjosmed@hotmail.com')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('31993624989')
    end

    it 'contains a message' do
      expect(parsed_email[:message]).to eq('Olá, gostaria de mais informações e condições para compra.')
    end

    it 'contains a description' do
      expect(parsed_email[:description]).to eq('Deseja contato por telefone')
    end

    it 'contains a product' do
      expect(parsed_email[:product]).to eq('Fat Bob')
    end
  end
end
