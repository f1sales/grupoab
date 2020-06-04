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
      else
        parse_website
      end

    end

    private

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
