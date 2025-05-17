# frozen_string_literal: true

require_relative "../question"
require_relative "../../instruction"

module Questionnaire
  module Questions
    # Final Question is the last question to be asked. It will ask the user to press enter to proceed,
    # and will also setup final setup instructions that need to be added at the end of each step.
    class FinalQuestion < Questionnaire::Question
      def ask
        app = data.answers[:app]
        puts ""
        puts "The steps to provision #{pastel.yellow.bold(app)} app are ready. Press #{pastel.yellow.bold("ENTER")} to proceed..."
        puts ""

        request_enter_to_continue
      end

      def setup_instructions
        app = data.answers[:app]

        data.removing_app << Instruction.command("dokku apps:destroy #{app}")
      end

      def request_enter_to_continue
        gets.chomp
      end
    end
  end
end
