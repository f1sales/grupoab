require 'ostruct'
require "f1sales_custom/parser"
require "f1sales_custom/source"

RSpec.describe F1SalesCustom::Email::Parser do

  context 'when it has different model' do
    let(:email){
      email = OpenStruct.new
      email.to = [email: 'leadsdomkt@abhdrj.f1sales.net'],
      email.subject = "Lead: Cliente interessado em Promoção Harley-Davidson via whatsapp"
      email.body = "Um cliente interssado em consórcio enviou os seguintes dados, e solicita\ncontato via whatsapp:\n\nO link para o veículo é:\nhttps://www.grupoab.com.br/harley-davidson/rio-harley/super-acao-digital/\nNome Washington Luiz\nTelefone 21964536465\nData 2020-05-25 1"

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq('Website')
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Washington Luiz')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('21964536465')
    end
  end

  context 'when is from Facebook' do
    let(:email){
      email = OpenStruct.new
      email.to = [email: 'leadsdomkt@abhdrj.f1sales.net'],
      email.subject = "Novo Lead BH Harley-Davidson - Ofertas | Facebook/Instagram",
      email.body = "Lead interessado em Ofertas da BH Harley-Davidson:\n\nNome: Angelo Gama\nEmail:angelo@conectt.net.br\nTelefone: +553186090965\nPretende comprar em: Estou apenas pesquisando\nMotocicleta de interesse: Fat Bob 114\n\nPlataforma: fb\n2020-05-29T00:03:57+0000"

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq('Facebook / Instagram (Por email)')
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Angelo Gama')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('angelo@conectt.net.br')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('3186090965')
    end

    it 'contains product' do
      expect(parsed_email[:product]).to eq('Fat Bob 114')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('Pretende comprar em: Estou apenas pesquisando')
    end
  end

  context 'when is the default template' do
    let(:email){
      email = OpenStruct.new
      email.to = [email: 'website@abhdrj.f1sales.net'],
      email.subject = 'Lead: Cliente interessado em veiculo novo',
      email.body = "Fat Bob\n\nUm cliente interssado em um veículo enviou os seguintes dados:\n\nO link para o veículo é:\nhttps://www.grupoab.com.br/harley-davidson/bh-harley/novos/fat-bob/\n\nNome\n\nTIAGO JEREMIAS DOS ANJOS\n\nE-mail\n\ntjanjosmed@hotmail.com\n\nTelefone\n\n31-99362-4989\n\nDeseja contato por telefone\n\nMensagem\n\nOlá, gostaria de mais informações e condições para compra.\n\nNewsletter\n\nData\n\n2020-05-21 11:37:12\n\nVeículo escolhido\n\nmodelo\n\nFat Bob\n\nmarca\n\nHarley-Davidson"

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains lead website a source name' do
      expect(parsed_email[:source][:name]).to eq('Website')
    end

    it 'contains an attachment' do
      expect(parsed_email[:attachments]).to eq(['https://www.grupoab.com.br/harley-davidson/bh-harley/novos/fat-bob/'])
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
