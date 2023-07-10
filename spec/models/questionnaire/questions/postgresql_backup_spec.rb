# frozen_string_literal: true

require_relative "../../../../models/data"
require_relative "../../../../models/questionnaire/questions/postgresql_backup"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::PostgresqlBackup do
  let(:data) { Data.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  describe "#ask" do
    before do
      allow(question).to receive(:prompt).and_return(prompt)
      allow(prompt).to receive(:yes?).and_return(true)
      allow(prompt).to receive(:ask).and_return("0 3 * * *", "<bucket_path>")
    end

    it "asks the user about regular backups and saves the answers in the data" do
      expect(prompt).to receive(:yes?)
        .and_return(true)

      expect(prompt).to receive(:ask)
        .with("Type the cron expression for the backup schedule", default: "\"0 3 * * *\"")
        .and_return("0 3 * * *")

      expect(prompt).to receive(:ask)
        .with("Type the path to the bucket on S3 where the backup will be stored", default: "<bucket_path>")
        .and_return("<bucket_path>")

      question.ask

      expect(data.answers[:postgresql_backup]).to eq(true)
      expect(data.answers[:cron_expression]).to eq("0 3 * * *")
      expect(data.answers[:backup_bucket_path]).to eq("<bucket_path>")
    end
  end

  describe "#eligible?" do
    context "when the answer to the 'postgresql' question is true" do
      before do
        data.add_answer(:postgresql, true)
      end

      it "returns true" do
        expect(question.eligible?).to eq(true)
      end
    end

    context "when the answer to the 'postgresql' question is false" do
      before do
        data.add_answer(:postgresql, false)
      end

      it "returns false" do
        expect(question.eligible?).to eq(false)
      end
    end
  end

  describe "#setup_instructions" do
    let(:app_name) { "my-app" }

    before do
      data.add_answer(:app, app_name)
      data.add_answer(:postgresql, true)
      data.add_answer(:postgresql_backup, true)
      data.add_answer(:cron_expression, "0 3 * * *")
      data.add_answer(:backup_bucket_path, "<bucket_path>")
    end

    it "adds setup instructions for configuring and scheduling database backups to the 'database' section of the data" do
      question.setup_instructions

      database_instructions = data.database
      expect(database_instructions).to be_an(Array)
      expect(database_instructions).not_to be_empty

      expect(database_instructions[0]).to be_a(Instruction)
      expect(database_instructions[0].type).to eq(:information)
      expect(database_instructions[0].text).to eq("When attaching a database to your app, you need to choose a name for it. To simplify")

      expect(database_instructions[1]).to be_a(Instruction)
      expect(database_instructions[1].type).to eq(:information)
      expect(database_instructions[1].text).to eq("your live and the future maintenance of your apps, we are going to use the name of ")

      expect(database_instructions[2]).to be_a(Instruction)
      expect(database_instructions[2].type).to eq(:information)
      expect(database_instructions[2].text).to eq("your app with the suffix '-database'. For example, if your app is called 'my-app', ")

      expect(database_instructions[3]).to be_a(Instruction)
      expect(database_instructions[3].type).to eq(:information)
      expect(database_instructions[3].text).to eq("your database will be called 'my-app-database'.\n\n")

      expect(database_instructions[4]).to be_a(Instruction)
      expect(database_instructions[4].type).to eq(:information)
      expect(database_instructions[4].text).to eq("Now, let's dive into the commands.\n\n")

      expect(database_instructions[5]).to be_a(Instruction)
      expect(database_instructions[5].type).to eq(:information)
      expect(database_instructions[5].text).to eq("\n\nTo backup your database, you first need configure your S3 credentials:")

      expect(database_instructions[6]).to be_a(Instruction)
      expect(database_instructions[6].type).to eq(:command)
      expect(database_instructions[6].text).to eq("dokku postgres:backup-auth #{app_name}-database <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>")

      expect(database_instructions[7]).to be_a(Instruction)
      expect(database_instructions[7].type).to eq(:information)
      expect(database_instructions[7].text).to eq("\n\nTo manually create a backup, run this command:")

      expect(database_instructions[8]).to be_a(Instruction)
      expect(database_instructions[8].type).to eq(:command)
      expect(database_instructions[8].text).to eq("dokku postgres:backup #{app_name}-database <bucket_path>")

      expect(database_instructions[9]).to be_a(Instruction)
      expect(database_instructions[9].type).to eq(:information)
      expect(database_instructions[9].text).to eq("\n\nTo schedule your backup, run this instead:")

      expect(database_instructions[10]).to be_a(Instruction)
      expect(database_instructions[10].type).to eq(:command)
      expect(database_instructions[10].text).to eq("dokku postgres:backup-schedule #{app_name}-database \"0 3 * * *\" <bucket_path>")
    end
  end
end
