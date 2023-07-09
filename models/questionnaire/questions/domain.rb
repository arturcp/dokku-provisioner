# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class Domain < Questionnaire::Question
      VARIABLE_NAME = "domain"

      def ask
        domain = prompt.ask("Domain:") { |q| q.required(true) }

        { domain: domain }
      end
    end
  end
end
