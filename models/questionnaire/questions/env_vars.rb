# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class EnvVars < Questionnaire::Question
      def ask
        puts ""
        puts "Environment variables"
        puts divider
        puts "You can paste all your environment variables in one shot. Make sure they are one per line and in the KEY=VALUE format, like this:"
        puts ""
        puts pastel.black.on_white("SITE_URL=https://my.site.com")
        puts pastel.black.on_white("SECRET_TOKEN=ABCD1234")
        puts pastel.black.on_white("WEBHOOK_URL=https://my.webhook.com/message")
        puts ""

        env_vars = prompt.multiline("Now, provide your environment variables:")

        { env_vars: env_vars }
      end
    end
  end
end
