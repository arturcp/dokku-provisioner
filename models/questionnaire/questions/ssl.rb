# frozen_string_literal: true

require_relative "../question"
require_relative "../../instruction"

module Questionnaire
  module Questions
    class SSL < Questionnaire::Question
      def ask
        ssl = prompt.yes?("Do you need a SSL certificate?")
        data.add_answer(:ssl, ssl)

        if ssl
          ssl_email = prompt.ask("SSL requires an email address:") { |q| q.required(true) }
          data.add_answer(:ssl_email, ssl_email)
        end
      end

      def setup_instructions
        return unless data.answers[:ssl]

        app = data.answers[:app]
        ssl_email = data.answers[:ssl_email]

        data.prerequisites << Instruction.command("dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git")
        data.prerequisites << Instruction.command("dokku letsencrypt:cron-job --add")


        data.ssl << Instruction.command("dokku letsencrypt:set #{app} email #{ssl_email}")
        data.ssl << Instruction.command("dokku letsencrypt:enable #{@app}")
      end
    end
  end
end
