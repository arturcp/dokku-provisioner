# frozen_string_literal: true

require_relative "../question"
require_relative "../../instruction"

module Questionnaire
  module Questions
    class AppName < Questionnaire::Question
      def ask
        app = prompt.ask("Name of the app:") { |q| q.required(true) }
        app = app.to_s.downcase.gsub(" ", "-")

        data.add_answer(:app, app)
      end

      def setup_instructions
        app = data.answers[:app]

        data.creating_app << Instruction.command("dokku apps:create #{app}")
        data.creating_app << Instruction.command("dokku git:initialize #{app}")
        data.creating_app << Instruction.command("dokku proxy:ports-set #{app} http:80:5000")
      end
    end
  end
end
