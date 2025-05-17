# frozen_string_literal: true

require_relative "../../../../models/provision_data"
require_relative "../../../../models/questionnaire/questions/domain"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::Domain do
  let(:data) { ProvisionData.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  before do
    allow(question).to receive(:prompt).and_return(prompt)
  end

  describe "#ask" do
    it "prompts the user for the domain and stores the answer in the data" do
      expect(prompt).to receive(:ask)
        .and_return("example.com")

      question.ask

      expect(data.answers[:domain]).to eq("example.com")
    end
  end

  describe "#setup_instructions" do
    let(:app_name) { "my-app" }

    before do
      data.add_answer(:app, app_name)
      data.add_answer(:server, "<HOSTNAME OR IP ADDRESS>")
    end

    context "when domain is provided" do
      let(:domain) { "example.com" }

      before do
        data.add_answer(:domain, domain)
      end

      it "adds domain-related setup instructions to the 'creating_app' section of the data" do
        question.setup_instructions

        creating_app_instructions = data.creating_app
        expect(creating_app_instructions).to be_an(Array)
        expect(creating_app_instructions).not_to be_empty

        expect(creating_app_instructions[0]).to be_a(Instruction)
        expect(creating_app_instructions[0].type).to eq(:command)
        expect(creating_app_instructions[0].text).to eq("dokku domains:add #{app_name} #{domain}")
      end
    end

    context "when domain is not provided" do
      it "does not add domain-related setup instructions" do
        question.setup_instructions

        creating_app_instructions = data.creating_app
        expect(creating_app_instructions).to be_an(Array)
        expect(creating_app_instructions).to be_empty
      end
    end

    it "adds deploying app instructions to the 'deploying_app' section of the data" do
      question.setup_instructions

      deploying_app_instructions = data.deploying_app
      expect(deploying_app_instructions).to be_an(Array)
      expect(deploying_app_instructions).not_to be_empty

      expect(deploying_app_instructions[0]).to be_a(Instruction)
      expect(deploying_app_instructions[0].type).to eq(:information)
      expect(deploying_app_instructions[0].text).to eq("You need to set up your local git config to point to a dokku remote.\n\n")

      expect(deploying_app_instructions[1]).to be_a(Instruction)
      expect(deploying_app_instructions[1].type).to eq(:information)
      expect(deploying_app_instructions[1].text).to eq("In your local environment, if you do not have a remote named `dokku` set, go to your")

      expect(deploying_app_instructions[2]).to be_a(Instruction)
      expect(deploying_app_instructions[2].type).to eq(:information)
      expect(deploying_app_instructions[2].text).to eq("project root folder and run:\n\n")

      expect(deploying_app_instructions[3]).to be_a(Instruction)
      expect(deploying_app_instructions[3].type).to eq(:command)
      expect(deploying_app_instructions[3].text).to eq("git remote add dokku dokku@<HOSTNAME OR IP ADDRESS>:#{app_name}")

      expect(deploying_app_instructions[4]).to be_a(Instruction)
      expect(deploying_app_instructions[4].type).to eq(:information)
      expect(deploying_app_instructions[4].text).to eq("\n\nHowever, if you already have it, you can change the IP address if needed:\n\n")

      expect(deploying_app_instructions[5]).to be_a(Instruction)
      expect(deploying_app_instructions[5].type).to eq(:command)
      expect(deploying_app_instructions[5].text).to eq("git remote set-url dokku dokku@<HOSTNAME OR IP ADDRESS>:#{app_name}")
    end
  end
end
