# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class SSLEmail < Questionnaire::Question
      def ask
        email = prompt.ask("SSL requires an email address:") { |q| q.required(true) }

        { ssl_email: email }
      end

      def eligible?
        answers[:ssl]
      end
    end
  end
end
