# frozen_string_literal: true

require_relative "../question"

module Questionnaire
  module Questions
    class PostgresqlBackup < Questionnaire::Question
      def ask
        postgresql_backup = prompt.yes?("Do you need to schedule regular backups of your database?")

        { postgresql_backup: postgresql_backup }
      end

      def eligible?
        answers[:postgresql]
      end
    end
  end
end
