# frozen_string_literal: true

require_relative "../question"
require_relative "../../instruction"

module Questionnaire
  module Questions
    class Domain < Questionnaire::Question
      def ask
        domain = prompt.ask("Domain:") { |q| q.required(true) }

        data.add_answer(:domain, domain)
      end

      def setup_instructions
        app = data.answers[:app]
        domain = data.answers[:domain]
        server = data.answers[:server]

        if domain && !domain.empty?
          data.creating_app << Instruction.command(
            "dokku domains:add #{app} #{domain}")
        end

        data.deploying_app << Instruction.information("In your local environment, if you do not have a remote named `dokku` set, go to your")
        data.deploying_app << Instruction.information("project root folder and run:\n\n")
        data.deploying_app << Instruction.command("git remote add dokku dokku@#{server}:#{app}")
        data.deploying_app << Instruction.information("\n\nHowever, if you already have it, you can change the IP address if needed:\n\n")
        data.deploying_app << Instruction.command("git remote set-url dokku dokku@#{server}:#{app}")
      end
    end
  end
end
