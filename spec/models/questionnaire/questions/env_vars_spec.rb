# frozen_string_literal: true

require_relative "../../../../models/provision_data"
require_relative "../../../../models/questionnaire/questions/env_vars"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::EnvVars do
  let(:data) { ProvisionData.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  describe "#ask" do
    before do
      allow(question).to receive(:prompt).and_return(prompt)
      allow(question).to receive(:puts)
      allow(prompt).to receive(:multiline)
    end

    it "displays instructions and prompts the user for environment variables" do
      expect(prompt).to receive(:multiline)
        .and_return(["KEY1=VALUE1\n", "KEY2=VALUE2\n"])

      question.ask

      expect(data.answers[:env_vars]).to eq(["KEY1=VALUE1", "KEY2=VALUE2"])
    end
  end

  describe "#setup_instructions" do
    let(:app_name) { "my-app" }
    let(:env_vars) { ["KEY1=VALUE1", "KEY2=VALUE2"] }

    before do
      data.add_answer(:app, app_name)
      data.add_answer(:env_vars, env_vars)
    end

    it "adds setup instructions for setting environment variables to the 'creating_app' section of the data" do
      question.setup_instructions

      creating_app_instructions = data.creating_app
      expect(creating_app_instructions).to be_an(Array)
      expect(creating_app_instructions).not_to be_empty

      expect(creating_app_instructions[0]).to be_a(Instruction)
      expect(creating_app_instructions[0].type).to eq(:command)
      expect(creating_app_instructions[0].text).to eq("dokku config:set --no-restart #{app_name} KEY1=VALUE1")

      expect(creating_app_instructions[1]).to be_a(Instruction)
      expect(creating_app_instructions[1].type).to eq(:command)
      expect(creating_app_instructions[1].text).to eq("dokku config:set --no-restart #{app_name} KEY2=VALUE2")
    end
  end
end
