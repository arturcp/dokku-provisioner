# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class AppName < Questionnaire::Question
      def ask
        app = prompt.ask("Name of the app:") { |q| q.required(true) }

        { app: app }
      end
    end
  end
end
