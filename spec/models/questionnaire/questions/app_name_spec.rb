# frozen_string_literal: true

require_relative "../../../../models/provision_data"
require_relative "../../../../models/questionnaire/questions/app_name"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::AppName do
  let(:app_name) { "my-app" }
  let(:data) { ProvisionData.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  before do
    allow(question).to receive(:prompt).and_return(prompt)
  end

  describe "#ask" do
    it "prompts the user for the app name and stores the answer in the data" do
      expect(prompt).to receive(:ask).and_return("My App")

      question.ask

      expect(data.answers[:app]).to eq(app_name)
    end
  end

  describe "#setup_instructions" do
    it "adds setup instructions to the 'creating_app' section of the data" do
      data.add_answer(:app, app_name)

      question.setup_instructions

      creating_app_instructions = data.creating_app
      expect(creating_app_instructions).to be_an(Array)
      expect(creating_app_instructions).not_to be_empty

      expect(creating_app_instructions[0]).to be_a(Instruction)
      expect(creating_app_instructions[0].type).to eq(:command)
      expect(creating_app_instructions[0].text).to eq("dokku apps:create my-app")

      expect(creating_app_instructions[1]).to be_a(Instruction)
      expect(creating_app_instructions[1].type).to eq(:command)
      expect(creating_app_instructions[1].text).to eq("dokku git:initialize my-app")
    end
  end
end
