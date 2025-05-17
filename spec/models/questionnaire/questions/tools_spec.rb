# frozen_string_literal: true

require_relative "../../../../models/provision_data"
require_relative "../../../../models/questionnaire/questions/tools"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::Tools do
  let(:data) { ProvisionData.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  before do
    allow(question).to receive(:prompt).and_return(prompt)
  end

  describe "#ask" do
    it "prompts the user to choose tools and stores the answers in the data" do
      expect(prompt).to receive(:multi_select)
        .and_return(["Postgresql"])

      question.ask

      expect(data.answers[:postgresql]).to eq(true)
      expect(data.answers[:redis]).to eq(false)
    end
  end

  describe "#setup_instructions" do
    let(:app_name) { "my-app" }

    before do
      data.add_answer(:app, app_name)
      data.add_answer(:postgresql, true)
      data.add_answer(:redis, true)
    end

    it "adds PostgreSQL-related and Redis-related setup instructions to the 'prerequisites', 'database', and 'removing_app' sections of the data" do
      question.setup_instructions

      prerequisites_instructions = data.prerequisites
      expect(prerequisites_instructions).to be_an(Array)
      expect(prerequisites_instructions).not_to be_empty

      expect(prerequisites_instructions[0]).to be_a(Instruction)
      expect(prerequisites_instructions[0].type).to eq(:information)
      expect(prerequisites_instructions[0].text).to eq("There are some steps you may need to take before setting up your app, like adding")

      expect(prerequisites_instructions[1]).to be_a(Instruction)
      expect(prerequisites_instructions[1].type).to eq(:information)
      expect(prerequisites_instructions[1].text).to eq("necessary plugins. You do not need to do these steps if you have already done them, ")

      expect(prerequisites_instructions[2]).to be_a(Instruction)
      expect(prerequisites_instructions[2].type).to eq(:information)
      expect(prerequisites_instructions[2].text).to eq("but if you run the commands again, it will not hurt anything.\n\n")

      expect(prerequisites_instructions[3]).to be_a(Instruction)
      expect(prerequisites_instructions[3].type).to eq(:information)
      expect(prerequisites_instructions[3].text).to eq("Before setting up your app, make sure you have dokku installed on your server. Now, ")

      expect(prerequisites_instructions[4]).to be_a(Instruction)
      expect(prerequisites_instructions[4].type).to eq(:information)
      expect(prerequisites_instructions[4].text).to eq("run the following commands on your server:\n\n")

      expect(prerequisites_instructions[5]).to be_a(Instruction)
      expect(prerequisites_instructions[5].type).to eq(:command)
      expect(prerequisites_instructions[5].text).to eq("dokku plugin:install https://github.com/dokku/dokku-postgres.git")

      expect(prerequisites_instructions[6]).to be_a(Instruction)
      expect(prerequisites_instructions[6].type).to eq(:command)
      expect(prerequisites_instructions[6].text).to eq("dokku plugin:install https://github.com/dokku/dokku-redis.git redis")

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
      expect(database_instructions[5].type).to eq(:command)
      expect(database_instructions[5].text).to eq("dokku postgres:create #{app_name}-database")

      expect(database_instructions[6]).to be_a(Instruction)
      expect(database_instructions[6].type).to eq(:command)
      expect(database_instructions[6].text).to eq("dokku postgres:link #{app_name}-database #{app_name}")

      redis_instructions = data.redis
      expect(redis_instructions).to be_an(Array)
      expect(redis_instructions).not_to be_empty

      expect(redis_instructions[0]).to be_a(Instruction)
      expect(redis_instructions[0].type).to eq(:information)
      expect(redis_instructions[0].text).to eq("When using redis in your app, you need to choose a name for it. To simplify your")

      expect(redis_instructions[1]).to be_a(Instruction)
      expect(redis_instructions[1].type).to eq(:information)
      expect(redis_instructions[1].text).to eq("life and the future maintenance of your apps, we are going to use the name of your")

      expect(redis_instructions[2]).to be_a(Instruction)
      expect(redis_instructions[2].type).to eq(:information)
      expect(redis_instructions[2].text).to eq("app with the suffix '-redis'. For example, if your app is called 'my-app', your redis")

      expect(redis_instructions[3]).to be_a(Instruction)
      expect(redis_instructions[3].type).to eq(:information)
      expect(redis_instructions[3].text).to eq("instance will be called 'my-app-redis'.\n\n")

      expect(redis_instructions[4]).to be_a(Instruction)
      expect(redis_instructions[4].type).to eq(:information)
      expect(redis_instructions[4].text).to eq("Now, run the following commands on your server:\n\n")

      expect(redis_instructions[5]).to be_a(Instruction)
      expect(redis_instructions[5].type).to eq(:command)
      expect(redis_instructions[5].text).to eq("dokku redis:create #{app_name}-redis")

      expect(redis_instructions[6]).to be_a(Instruction)
      expect(redis_instructions[6].type).to eq(:command)
      expect(redis_instructions[6].text).to eq("dokku redis:link #{app_name}-redis #{app_name}")

      expect(redis_instructions[7]).to be_a(Instruction)
      expect(redis_instructions[7].type).to eq(:information)
      expect(redis_instructions[7].text).to eq("\n\nIf you use workers to deal with Redis, you can manually start them with this command:")

      expect(redis_instructions[8]).to be_a(Instruction)
      expect(redis_instructions[8].type).to eq(:command)
      expect(redis_instructions[8].text).to eq("dokku ps:scale #{app_name} worker=1")

      expect(redis_instructions[9]).to be_a(Instruction)
      expect(redis_instructions[9].type).to eq(:information)
      expect(redis_instructions[9].text).to eq("\n\nBut you can also add a :worker instruction to your project's Procfile, and Dokku will automatically start it for you.")

      expect(redis_instructions[10]).to be_a(Instruction)
      expect(redis_instructions[10].type).to eq(:information)
      expect(redis_instructions[10].text).to eq("For example, you can add this to your Procfile:\n\n")

      expect(redis_instructions[11]).to be_a(Instruction)
      expect(redis_instructions[11].type).to eq(:example)
      expect(redis_instructions[11].text).to eq("worker: bundle exec sidekiq -c 3 -v")

      removing_app_instructions = data.removing_app
      expect(removing_app_instructions).to be_an(Array)
      expect(removing_app_instructions).not_to be_empty

      expect(removing_app_instructions[0]).to be_a(Instruction)
      expect(removing_app_instructions[0].type).to eq(:information)
      expect(removing_app_instructions[0].text).to eq("In case you ever need to delete your app, here are the steps to clean up everything:\n\n")

      expect(removing_app_instructions[1]).to be_a(Instruction)
      expect(removing_app_instructions[1].type).to eq(:command)
      expect(removing_app_instructions[1].text).to eq("dokku postgres:unlink #{app_name}-database #{app_name}")

      expect(removing_app_instructions[2]).to be_a(Instruction)
      expect(removing_app_instructions[2].type).to eq(:command)
      expect(removing_app_instructions[2].text).to eq("dokku postgres:destroy #{app_name}-database")
    end

    # it "adds Redis-related setup instructions to the 'prerequisites', 'redis', and 'removing_app' sections of the data" do
    #   question.setup_instructions

    #   prerequisites_instructions = data.prerequisites
    #   expect(prerequisites_instructions).to be_an(Array)
    #   expect(prerequisites_instructions).not_to be_empty

    #   expect(prerequisites_instructions[0]).to be_a(Instruction)
    #   expect(prerequisites_instructions[0].type).to eq(:information)
    #   expect(prerequisites_instructions[0].text).to eq("There are some steps you may need to take before setting up your app, like adding")

    #   expect(prerequisites_instructions[1]).to be_a(Instruction)
    #   expect(prerequisites_instructions[1].type).to eq(:information)
    #   expect(prerequisites_instructions[1].text).to eq("necessary plugins. You do not need to do these steps if you have already done them, ")

    #   expect(prerequisites_instructions[2]).to be_a(Instruction)
    #   expect(prerequisites_instructions[2].type).to eq(:information)
    #   expect(prerequisites_instructions[2].text).to eq("but if you run the commands again, it will not hurt anything.\n\n")

    #   expect(prerequisites_instructions[3]).to be_a(Instruction)
    #   expect(prerequisites_instructions[3].type).to eq(:information)
    #   expect(prerequisites_instructions[3].text).to eq("Before setting up your app, make sure you have dokku installed on your server. Now, ")

    #   expect(prerequisites_instructions[4]).to be_a(Instruction)
    #   expect(prerequisites_instructions[4].type).to eq(:information)
    #   expect(prerequisites_instructions[4].text).to eq("run the following commands on your server:\n\n")

    #   expect(prerequisites_instructions[5]).to be_a(Instruction)
    #   expect(prerequisites_instructions[5].type).to eq(:command)
    #   expect(prerequisites_instructions[5].text).to eq("dokku plugin:install https://github.com/dokku/dokku-postgres.git")




    #   removing_app_instructions = data.removing_app
    #   expect(removing_app_instructions).to be_an(Array)
    #   expect(removing_app_instructions).not_to be_empty

    #   expect(removing_app_instructions[0]).to be_a(Instruction)
    #   expect(removing_app_instructions[0].type).to eq(:command)
    #   expect(removing_app_instructions[0].text).to eq("dokku redis:unlink #{app_name}-redis #{app_name}")

    #   expect(removing_app_instructions[1]).to be_a(Instruction)
    #   expect(removing_app_instructions[1].type).to eq(:command)
    #   expect(removing_app_instructions[1].text).to eq("dokku redis:destroy #{app_name}-redis")
    # end
  end
end
