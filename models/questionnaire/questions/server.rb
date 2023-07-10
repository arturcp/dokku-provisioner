# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class Server < Questionnaire::Question
      PLACEHOLDER = "<HOSTNAME OR IP ADDRESS>"

      def ask
        if servers.length > 1
          server = prompt.select("To which server are you going to deploy your app?",
            servers)
        else
          server = servers.first || PLACEHOLDER
        end

        data.add_answer(:server, server)
      end

      def setup_instructions
      end

      private

      def servers
        @servers ||= ENV.fetch("DOKKU_SERVERS", "").split(",").map(&:strip)
      end
    end
  end
end
