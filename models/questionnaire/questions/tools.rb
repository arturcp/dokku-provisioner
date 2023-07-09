# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class Tools < Questionnaire::Question
      AVAILABLE_TOOLS = [
        "Postgresql",
        "Redis"
      ].freeze

      def ask
        selected_tools = prompt.multi_select("Choose the tools you will need",
          AVAILABLE_TOOLS, per_page: AVAILABLE_TOOLS.length, echo: true)

        {
          postgresql: selected_tools.include?("Postgresql"),
          redis: selected_tools.include?("Redis")
        }
      end
    end
  end
end
