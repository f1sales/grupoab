require "grupoab/version"

require "f1sales_custom/parser"
require "f1sales_custom/source"
require "f1sales_helpers"

module Grupoab
  class Error < StandardError; end
  class F1SalesCustom::Email::Source
    def self.all
      [
        {
          email_id: 'leadsdomkt',
          name: 'Leads do Marketing'
        }
      ]
    end

    def self.support?(_email_id)
      true
    end
  end

  class F1SalesCustom::Email::Parser
    def parse

      brand_store = extract_brand_store

      if @email.subject.downcase.include?('facebook')
        parse_facebook(brand_store)
      elsif @email.from[:email].include?('mercadolivre')
        parse_mercadolivre(brand_store)
      elsif @email.from[:email].include?('olx')
        parser = OLXParser.new(@email)
        lead_payload = parser.parse
        lead_payload[:source][:name] = "#{brand_store}#{lead_payload[:source][:name]}"
        lead_payload
      elsif @email.from[:email].include?('icarros')
        parser = ICarrosParser.new(@email)
        lead_payload = parser.parse
        lead_payload[:source][:name] = "#{brand_store}#{lead_payload[:source][:name]}"
        lead_payload
      elsif @email.from[:email].include?('mobiauto')
        parser = MobiautoParser.new(@email)
        lead_payload = parser.parse
        lead_payload[:source][:name] = "#{brand_store}#{lead_payload[:source][:name]}"
        lead_payload
      elsif @email.from[:email].include?('moto.com.br')
        parse_motocom(brand_store)
      else
        parse_website(brand_store)
      end
    end

    private

    def extract_brand_store
      default_email_to = F1SalesCustom::Email::Source.all[0][:email_id]
      destinatary = @email.to.map { |e| e[:email] }.first
      return '' if destinatary.include?(default_email_to)

      destinatary_name = destinatary.split('@').first
      brand, store_name = destinatary_name.split('.').map(&:capitalize)
      return "#{destinatary_name.capitalize} - " unless brand && store_name

      "#{brand} - #{store_name} - "
    end

    def parse_mercadolivre(brand_store)
      raise 'Not an email lead' unless @email.subject.downcase.include?('fizeram uma pergunta no anuncio')

      parsed_email = @email.body.colons_to_hash(/(Estes sãos os dados do interessado|fizeram uma pergunta para você|Telefone|Responder).*?/, false)
      name, email = parsed_email['estes_sos_os_dados_do_interessado'].split("\n").map(&:strip).reject(&:empty?).select { |data| data.size > 1}
      email = email.split(" ").first
      product = parsed_email['fizeram_uma_pergunta_para_voc'].split("\n")[1].strip
      product = product.split(" ")[0..-2].join(' ')


      {
        source: {
          name: "#{brand_store}Mercado Livre Por Email",
        },
        customer: {
          name: name,
          phone: parsed_email['telefone'].tr('^0-9', ''),
          email: email,
        },
        product: { name: product },
        description: '',
        message: parsed_email['fizeram_uma_pergunta_para_voc'].split("\n").last.strip
      }
    end

    def parse_motocom(brand_store)
      raise 'Not an email lead' unless @email.subject.downcase.include?('proposta')

      parsed_email = @email.body.colons_to_hash(/(Telefone|E-mail do Interessado|Responder agora|Dados do interessado|Nome|Proposta).*?:/, false)

      product = @email.subject.split(" - ")[1..2].join(' - ')
      description = @email.body.split("\n\n")[2].split(' - ')[2..3].join(' - ')

      {
        source: {
          name: "#{brand_store}Moto.com.br"
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', ''),
          email: parsed_email['email_do_interessado'],
        },
        product: { name: product },
        description: description,
        message: parsed_email["proposta"]
      }
    end

    def parse_website(brand_store)
      return if @email.subject.include?('Mercado Livre Ofertas')

      parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|modelo|versao|Newsletter|marca|Mensagem|O link para o veículo é|E-mail|Deseja contato|Data).*?/, false) unless parsed_email

      email = parsed_email['email']
      phone = parsed_email['telefone']

      raise "Not able to parse lead #{@email.body}" unless email || phone

      attachments = URI.extract(@email.body, 'https') || []

      {
        source: {
          name: brand_store == 'Website - ' ? 'Website' : "#{brand_store}Website"
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', ''),
          email: parsed_email['email'],
        },
        product: { name: (parsed_email['modelo'] || '') },
        message: parsed_email['mensagem'],
        description: "#{@email.subject} | Deseja contato #{(parsed_email['deseja_contato'] || '').gsub("\n", ' ')}",
        attachments: attachments
      }
    end

    def parse_facebook(brand_store)
      parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|Email|Pretende comprar em|Motocicleta de interesse|Plataforma).*?:/, false) unless parsed_email

      {
        source: {
          name: "#{brand_store}Facebook / Instagram (Por email)"
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', '')[2..-1],
          email: parsed_email['email'],
        },
        product: { name: parsed_email['motocicleta_de_interesse'] },
        description: @email.subject,
        message: "Pretende comprar em: #{parsed_email['pretende_comprar_em']}"
      }
    end
  end
end
