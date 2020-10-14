require 'ostruct'
require "f1sales_custom/parser"
require "f1sales_custom/source"

RSpec.describe F1SalesCustom::Email::Parser do

  context 'when is from Mercado Livre' do
    let(:email){
      email = OpenStruct.new
      email.to = [email: 'leadsdomkt@abhdrj.f1sales.net']
      email.from = { email: 'nao-responder@mercadolivre.com' }
      email.subject = 'Fizeram uma pergunta no anuncio Harley Davidson Road Glide!'
      email.body = "Olá, Ricardo Vinícius, fizeram uma pergunta para você \n    \n     \n    \n    \n   (https://moto.mercadolivre.com.br/MLB-1418873117-harley-davidson-road-glide-_JM) \n Harley Davidson Road Glide (https://moto.mercadolivre.com.br/MLB-1418873117-harley-davidson-road-glide-_JM) \n    \n 75000 a vista??? \n  \nEstes sãos os dados do interessado: \n  \nAngelo Butrus \n  angelobutrus@hotmail.com (mailto:angelobutrus@hotmail.com) \n  \nTelefone: 62-981060717 \n    \n    \n  Responder (https://questions.mercadolivre.com.br/seller?item=MLB1418873117&confirm=true&_consistent=true)  \n    \n    \n    \n  \nPrecisa de ajuda? Entre em contato conosco (https://www.mercadolivre.com.br/ajuda) \nCompre e venda do seu celular!   \n Te enviamos este e-mail para ml.hd.bh@grupoab.com.br porque você optou por receber informações. (mailto:ml.hd.bh@grupoab.com.br) \nAdministrar preferências de e-mails. (https://myaccount.mercadolivre.com.br/preferences/emails) \nVeja como cuidamos da sua Privacidade e confira os (https://www.mercadolivre.com.br/privacidade) Termos e condições do Mercado Livre. (https://www.mercadolivre.com.br/ajuda/991)"

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains Mercado Livre Email as source name' do
      expect(parsed_email[:source][:name]).to eq('Mercado Livre Por Email')
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Angelo Butrus')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('62981060717')
    end

    it 'contains product' do
      expect(parsed_email[:product]).to eq('Harley Davidson Road Glide')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('angelobutrus@hotmail.com')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('75000 a vista???')
    end
  end

  context 'when is from Moto.com' do
    let(:email){
      email = OpenStruct.new
      email.to = [email: 'leadsdomkt@abhdrj.f1sales.net']
      email.from = { email: 'atendimento@moto.com.br' }
      email.subject = 'Proposta para sua Harley-Davidson - Fat Boy 107 - 2019'
      email.body = "Moto.com.br O canal da Moto\n\nOlá parceiro Motociclista!\n\nVale, enviou uma mensagem para você, sobre a moto %ANUNCIO_MARCA_MODELO%% - 2019 - Preta - $63,900.00\n\nDados da proposta\nNome : Vale \nE-mail do Interessado: joaobragapc@bol.com.br \nTelefone : 31 39123788 \nProposta : Fecha em 60 mil a vista ?\n \n\nResponder agora: http://www.moto.com.br/anunciosv2/fechado/chatProposta.html?loginHashParam=rO0ABXNyACdici5jb20ubW90by5zZXJpYWxpemVkLnV0aWwuQ3VzdG9tTG9naW5Rpl5k64KhcwIAA0wACm1lbnNhZ2VtSDF0ABJMamF2YS9sYW5nL1N0cmluZztMAAptZW5zYWdlbUgycQB+AAFMAA51c3VhcmlvV3JhcHBlcnQALExici9jb20vbW90by9zZXJpYWxpemVkL3V0aWwvVXN1YXJpb1dyYXBwZXI7eHIALmJyLmNvbS5tb3RvLnNlcmlhbGl6ZWQudXRpbC5TZXJpYWxpemVibGVPYmplY3QD3J3Z02TLzwIAAHhwdAAWUmVzcG9uZGEgc3VhIHByb3Bvc3RhIXQAOFZvYyZlY2lyYzsgcG9kZSBuZWdvY2lhciB2aWEgY2hhdCEgRW50cmUgZSBuZWdvY2llIGFnb3Jhc3IAKmJyLmNvbS5tb3RvLnNlcmlhbGl6ZWQudXRpbC5Vc3VhcmlvV3JhcHBlcqZGh1ZnFu/8AgAETAAFZW1haWxxAH4AAUwAAmlkdAAQTGphdmEvbGFuZy9Mb25nO0wABG5vbWVxAH4AAUwABnN0YXR1c3QAFUxqYXZhL2xhbmcvQ2hhcmFjdGVyO3hxAH4AA3QAG21vdG9jb21ici1hYmFoZEBmMXNhbGVzLm9yZ3NyAA5qYXZhLmxhbmcuTG9uZzuL5JDMjyPfAgABSgAFdmFsdWV4cgAQamF2YS5sYW5nLk51bWJlcoaslR0LlOCLAgAAeHAAAAAAAAOsJXQABkFCQSBIRHNyABNqYXZhLmxhbmcuQ2hhcmFjdGVyNItH2WsaJngCAAFDAAV2YWx1ZXhwAEE=\n\t\t\n\t\t\t\nNão perca tempo\nresponda seu anúncio!\n\t\t\t\nAtenciosamente Moto.com.br"

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains moto.com.br as source name' do
      expect(parsed_email[:source][:name]).to eq('Moto.com.br')
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Vale')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('3139123788')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('joaobragapc@bol.com.br')
    end

    it 'contains product' do
      expect(parsed_email[:product]).to eq('Fat Boy 107 - 2019')
    end

    it 'contains description' do
      expect(parsed_email[:description]).to eq('Preta - $63,900.00')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('Fecha em 60 mil a vista ?')
    end

  end

  context 'when is not a lead' do
    let(:email){
      email = OpenStruct.new
      email.from = { email: 'atendimento@foo.com.br' }
      email.to = [email: 'leadsdomkt@abhdrj.f1sales.net']
      email.subject = " "
      email.body = " "

      email
    }

    it 'raise an error' do
      expect { described_class.new(email).parse }.to raise_error('Not able to parse lead  ')
    end

  end

  context 'when it has different model' do
    let(:email){
      email = OpenStruct.new
      email.from = { email: 'atendimento@foo.com.br' }
      email.to = [email: 'leadsdomkt@abhdrj.f1sales.net']
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

    context 'when is volvo' do
      let(:email){
        email = OpenStruct.new
        email.to = [email: 'volvo.gotland@abnpa.f1sales.net']
        email.from = { email: 'atendimento@foo.com.br' }
        email.subject = "Novo Lead BH Harley-Davidson - Ofertas | Facebook/Instagram"
        email.body = "Lead interessado em Ofertas da BH Harley-Davidson:\n\nNome: Angelo Gama\nEmail:angelo@conectt.net.br\nTelefone: +553186090965\nPretende comprar em: Estou apenas pesquisando\nMotocicleta de interesse: Fat Bob 114\n\nPlataforma: fb\n2020-05-29T00:03:57+0000"

        email
      }

      let(:parsed_email) { described_class.new(email).parse }

      it 'contains lead website a source name' do
        expect(parsed_email[:source][:name]).to eq('Volvo - Gotland - Facebook / Instagram (Por email)')
      end
    end

    context 'when brand is not specided' do

      let(:email){
        email = OpenStruct.new
        email.to = [email: 'leadsdomkt@abhdrj.f1sales.net']
        email.from = { email: 'atendimento@foo.com.br' }
        email.subject = "Novo Lead BH Harley-Davidson - Ofertas | Facebook/Instagram"
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
  end

  context 'when is the default template' do

    context 'when brand is specied' do

      context 'when is VW' do
        let(:email){
          email = OpenStruct.new
          email.to = [email: 'seminovos@grupoab.com.br']
          email.from = { email: 'dgyleads@gmail.com' }
          email.subject = 'Lead AB Seminovos - Intermediário | Facebook/Instagram'
          email.body = "Fat Bob\n\nUm cliente interssado em um veículo enviou os seguintes dados:\n\nO link para o veículo é:\nhttps://www.grupoab.com.br/harley-davidson/bh-harley/novos/fat-bob/\n\nNome\n\nTIAGO JEREMIAS DOS ANJOS\n\nE-mail\n\ntjanjosmed@hotmail.com\n\nTelefone\n\n31-99362-4989\n\nDeseja contato por telefone\n\nMensagem\n\nOlá, gostaria de mais informações e condições para compra.\n\nNewsletter\n\nData\n\n2020-05-21 11:37:12\n\nVeículo escolhido\n\nmodelo\n\nFat Bob\n\nmarca\n\nHarley-Davidson"

          email
        }

        let(:parsed_email) { described_class.new(email).parse }

        it 'contains lead website a source name' do
          expect(parsed_email[:source][:name]).to eq('Seminovos - Facebook / Instagram (Por email)')
        end

        it 'contains a description' do
          expect(parsed_email[:description]).to eq('Lead AB Seminovos - Intermediário | Facebook/Instagram')
        end
      end

      context 'when is volvo' do
        let(:email){
          email = OpenStruct.new
          email.to = [email: 'volvo.gotland@abhdrj.f1sales.net']
          email.from = { email: 'atendimento@foo.com.br' }
          email.subject = 'Lead: Cliente interessado em veiculo novo'
          email.body = "Fat Bob\n\nUm cliente interssado em um veículo enviou os seguintes dados:\n\nO link para o veículo é:\nhttps://www.grupoab.com.br/harley-davidson/bh-harley/novos/fat-bob/\n\nNome\n\nTIAGO JEREMIAS DOS ANJOS\n\nE-mail\n\ntjanjosmed@hotmail.com\n\nTelefone\n\n31-99362-4989\n\nDeseja contato por telefone\n\nMensagem\n\nOlá, gostaria de mais informações e condições para compra.\n\nNewsletter\n\nData\n\n2020-05-21 11:37:12\n\nVeículo escolhido\n\nmodelo\n\nFat Bob\n\nmarca\n\nHarley-Davidson"

          email
        }

        let(:parsed_email) { described_class.new(email).parse }

        it 'contains lead website a source name' do
          expect(parsed_email[:source][:name]).to eq('Volvo - Gotland - Website')
        end
      end
    end

    context 'when brand is not specified' do

      let(:email){
        email = OpenStruct.new
        email.to = [email: 'website@abhdrj.f1sales.net']
        email.from = { email: 'atendimento@foo.com.br' }
        email.subject = 'Lead: Cliente interessado em veiculo novo'
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
        expect(parsed_email[:description]).to eq('Lead: Cliente interessado em veiculo novo | Deseja contato por telefone')
      end

      it 'contains a product' do
        expect(parsed_email[:product]).to eq('Fat Bob')
      end
    end
  end
end
