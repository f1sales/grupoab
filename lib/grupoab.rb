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
          email_id: 'website',
          name: 'Website'
        },
      ]
    end
  end

  class F1SalesCustom::Email::Parser
    def parse

      parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|modelo|Newsletter|marca|Mensagem|E-mail|Deseja contato).*?\n\n/, false) unless parsed_email

      {
        source: {
          name: F1SalesCustom::Email::Source.all[0][:name],
        },
        customer: {
          name: parsed_email['nome'],
          phone: (parsed_email['telefone'] || '').tr('^0-9', ''),
          email: parsed_email['email'],
        },
        product: parsed_email['modelo'],
        message: parsed_email['mensagem'],
        description: "Deseja contato por #{parsed_email['deseja_contato']}",
      }
    end
  end
end
