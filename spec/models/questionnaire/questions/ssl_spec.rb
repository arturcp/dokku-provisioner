# frozen_string_literal: true

require_relative "../../../../models/data"
require_relative "../../../../models/questionnaire/questions/ssl"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::SSL do
  let(:data) { Data.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  describe "#ask" do
    before do
      allow(question).to receive(:prompt).and_return(prompt)
      allow(prompt).to receive(:yes?).and_return(true)
      allow(prompt).to receive(:ask).and_return("test@example.com")
    end

    it "asks the user about SSL and saves the answers in the data" do
      expect(prompt).to receive(:yes?)
        .and_return(true)

      expect(prompt).to receive(:ask)
        .and_return("test@example.com")

      question.ask

      expect(data.answers[:ssl]).to eq(true)
      expect(data.answers[:ssl_email]).to eq("test@example.com")
    end
  end

  describe "#setup_instructions" do
    let(:app_name) { "my-app" }

    before do
      data.add_answer(:app, app_name)
      data.add_answer(:ssl, true)
      data.add_answer(:ssl_email, "test@example.com")
    end

    it "adds setup instructions for SSL to the 'prerequisites' and 'ssl' sections of the data" do
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
      expect(prerequisites_instructions[5].text).to eq("dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git")

      expect(prerequisites_instructions[6]).to be_a(Instruction)
      expect(prerequisites_instructions[6].type).to eq(:command)
      expect(prerequisites_instructions[6].text).to eq("dokku letsencrypt:cron-job --add")

      ssl_instructions = data.ssl
      expect(ssl_instructions).to be_an(Array)
      expect(ssl_instructions).not_to be_empty

      expect(ssl_instructions[0]).to be_a(Instruction)
      expect(ssl_instructions[0].type).to eq(:information)
      expect(ssl_instructions[0].text).to eq("To allow users to access your app using http, you need to configure SSL. To do so,")

      expect(ssl_instructions[1]).to be_a(Instruction)
      expect(ssl_instructions[1].type).to eq(:information)
      expect(ssl_instructions[1].text).to eq("you need to follow these steps:\n\n")

      expect(ssl_instructions[2]).to be_a(Instruction)
      expect(ssl_instructions[2].type).to eq(:command)
      expect(ssl_instructions[2].text).to eq("dokku letsencrypt:set #{app_name} email test@example.com")

      expect(ssl_instructions[3]).to be_a(Instruction)
      expect(ssl_instructions[3].type).to eq(:command)
      expect(ssl_instructions[3].text).to eq("dokku letsencrypt:enable #{@app}")
    end
  end
end
