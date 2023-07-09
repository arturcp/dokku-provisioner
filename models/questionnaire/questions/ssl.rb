# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class SSL < Questionnaire::Question
      def ask
        ssl = prompt.yes?("Do you need a SSL certificate?")

        { ssl: ssl }
      end
    end
  end
end
