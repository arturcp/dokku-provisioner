# frozen_string_literal: true

require_relative "../question"
require_relative "../../instruction"

module Questionnaire
  module Questions
    class PostgresqlBackup < Questionnaire::Question
      def ask
        postgresql_backup = prompt.yes?("Do you need to schedule regular backups of your database and save it on S3?")
        data.add_answer(:postgresql_backup, postgresql_backup)

        if postgresql_backup
          cron_expression = prompt.ask("Type the cron expression for the backup schedule", default: "\"0 3 * * *\"")
          backup_bucket_path = prompt.ask("Type the path to the bucket on S3 where the backup will be stored", default: "<bucket_path>")

          data.add_answer(:cron_expression, cron_expression)
          data.add_answer(:backup_bucket_path, backup_bucket_path)
        end
      end

      def eligible?
        data.answers[:postgresql]
      end

      def setup_instructions
        return if !eligible? || !data.answers[:postgresql_backup]

        app = data.answers[:app]
        cron_expression = data.answers[:cron_expression]
        bucket_path = data.answers[:backup_bucket_path]

        database = "#{app}-database"

        data.database << Instruction.information("\n\nTo backup your database, you first need configure your S3 credentials:")
        data.database << Instruction.command("dokku postgres:backup-auth #{database} #{aws_access_key_id} #{aws_secret_access_key}")

        data.database << Instruction.information("\n\nTo manually create a backup, run this command:")
        data.database << Instruction.command("dokku postgres:backup #{database} #{bucket_path}")

        data.database << Instruction.information("\n\nTo schedule your backup, run this instead:")
        data.database << Instruction.command("dokku postgres:backup-schedule #{database} \"#{cron_expression}\" #{bucket_path}")
      end

      private

      def aws_access_key_id
        ENV.fetch("AWS_ACCESS_KEY_ID", "<AWS_ACCESS_KEY_ID>")
      end

      def aws_secret_access_key
        ENV.fetch("AWS_SECRET_ACCESS_KEY", "<AWS_SECRET_ACCESS_KEY>")
      end
    end
  end
end
