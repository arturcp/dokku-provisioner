# frozen_string_literal: true

require_relative "../question"
require_relative "../../instruction"

module Questionnaire
  module Questions
    class Tools < Questionnaire::Question
      AVAILABLE_TOOLS = ["Postgresql", "Redis"].freeze

      def ask
        selected_tools = prompt.multi_select("Choose the tools you will need",
          AVAILABLE_TOOLS, per_page: AVAILABLE_TOOLS.length, echo: true)

        data.add_answer(:postgresql, selected_tools.include?("Postgresql"))
        data.add_answer(:redis, selected_tools.include?("Redis"))
      end

      def setup_instructions
        app = data.answers[:app]
        postgresql = data.answers[:postgresql]
        redis = data.answers[:redis]

        setup_postgresql(app) if postgresql
        setup_redis(app) if redis
      end

      private

      def setup_postgresql(app)
        data.prerequisite << Instruction.command(
          "dokku plugin:install https://github.com/dokku/dokku-postgres.git")

        data.database << Instruction.command("dokku postgres:create #{app}-database")
        data.database << Instruction.command("dokku postgres:link #{app}-database #{app}")

        data.removing_app << Instruction.command("dokku postgres:unlink #{app}-database #{app}")
        data.removing_app << Instruction.command("dokku postgres:destroy #{app}-database")
      end

      def setup_redis(app)
        data.prerequisite << Instruction.command(
          "dokku plugin:install https://github.com/dokku/dokku-redis.git redis")

        data.redis << Instruction.command("dokku redis:create #{app}-redis")
        data.redis << Instruction.command("dokku redis:link #{app}-redis #{app}")

        data.redis << Instruction.information("\n\nIf you use workers to deal with Redis, you can manually start them with this command:")
        data.redis << Instruction.command("dokku ps:scale #{app} worker=1")
        data.redis << Instruction.information("\n\nBut you can also add a :worker instruction to your project's Procfile, and Dokku will automatically start it for you.")
        data.redis << Instruction.information("For example, you can add this to your Procfile:\n\n")
        data.redis << Instruction.example("worker: bundle exec sidekiq -c 3 -v")

        data.removing_app << Instruction.command("dokku redis:unlink #{app}-redis #{app}")
        data.removing_app << Instruction.command("dokku redis:destroy #{app}-redis")
      end
    end
  end
end
