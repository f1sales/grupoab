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
        },
      ]
    end

    def self.support?(_email_id)
      true
    end
  end

  class F1SalesCustom::Email::Parser
    def parse

      if @email.subject.downcase.include?('facebook')
        parse_facebook
      elsif @email.from[:email].include?('mercadolivre')
        parse_mercadolivre
      elsif @email.from[:email].include?('moto.com.br')
        parse_motocom
      else
        parse_website
      end

    end

    private

    def parse_mercadolivre
      raise 'Not an email lead' unless @email.subject.downcase.include?('fizeram uma pergunta no anuncio')
      parsed_email = @email.body.colons_to_hash(/(Estes sãos os dados do interessado|fizeram uma pergunta para você|Telefone|Responder).*?/, false)
      name, email = parsed_email['estes_sos_os_dados_do_interessado'].split("\n").map(&:strip).reject(&:empty?).select { |data| data.size > 1}
      email = email.split(" ").first
      product = parsed_email['fizeram_uma_pergunta_para_voc'].split("\n")[1].strip
      product = product.split(" ")[0..-2].join(' ')


      {
        source: {
          name: 'Mercado Livre Por Email',
        },
        customer: {
          name: name,
          phone: parsed_email['telefone'].tr('^0-9', ''),
          email: email,
        },
        product: product,
        description: '',
        message: parsed_email['fizeram_uma_pergunta_para_voc'].split("\n").last.strip
      }
    end

    def parse_motocom
      raise 'Not an email lead' unless @email.subject.downcase.include?('proposta')

      parsed_email = @email.body.colons_to_hash(/(Telefone|E-mail do Interessado|Responder agora|Dados do interessado|Nome|Proposta).*?:/, false)

      product = @email.subject.split(" - ")[1..2].join(' - ')
      description = @email.body.split("\n\n")[2].split(' - ')[2..3].join(' - ')

      {
        source: {
          name: 'Moto.com.br',
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', ''),
          email: parsed_email['email_do_interessado'],
        },
        product: product,
        description: description,
        message: parsed_email["proposta"]
      }
    end

    def parse_website

      return if @email.subject.include?('Mercado Livre Ofertas')
      parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|modelo|versao|Newsletter|marca|Mensagem|O link para o veículo é|E-mail|Deseja contato|Data).*?/, false) unless parsed_email

      email = parsed_email['email']
      phone = parsed_email['telefone']

      unless email || phone
        raise "Not able to parse lead #{@email.body}"
      end

      {
        source: {
          name: 'Website',
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', ''),
          email: parsed_email['email'],
        },
        product: (parsed_email['modelo'] || ''),
        message: parsed_email['mensagem'],
        description: "Deseja contato #{(parsed_email['deseja_contato'] || '').gsub("\n", ' ')}",
        attachments: [(parsed_email['o_link_para_o_veculo_'] || '').gsub(":\n", '')]
      }

    end

    def parse_facebook
      parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|Email|Pretende comprar em|Motocicleta de interesse|Plataforma).*?:/, false) unless parsed_email

      {
        source: {
          name: 'Facebook / Instagram (Por email)',
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', '')[2..-1],
          email: parsed_email['email'],
        },
        product: parsed_email['motocicleta_de_interesse'],
        message: "Pretende comprar em: #{parsed_email['pretende_comprar_em']}",
      }
    end
  end
end
