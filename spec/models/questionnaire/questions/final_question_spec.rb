# frozen_string_literal: true

require_relative "../../../../models/data"
require_relative "../../../../models/questionnaire/questions/final_question"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::FinalQuestion do
  let(:data) { Data.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  describe "#ask" do
    before do
      allow(question).to receive(:prompt).and_return(prompt)
      allow(question).to receive(:puts)
      allow(question).to receive(:request_enter_to_continue)
    end

    it "displays the final message and waits for user input" do
      expect(question).to receive(:puts).exactly(3).times

      question.ask
    end
  end

  describe "#setup_instructions" do
    let(:app_name) { "my-app" }

    before do
      data.add_answer(:app, app_name)
    end

    it "adds setup instructions for removing the app to the 'removing_app' section of the data" do
      question.setup_instructions

      removing_app_instructions = data.removing_app
      expect(removing_app_instructions).to be_an(Array)
      expect(removing_app_instructions).not_to be_empty

      expect(removing_app_instructions[0]).to be_a(Instruction)
      expect(removing_app_instructions[0].type).to eq(:information)
      expect(removing_app_instructions[0].text).to eq("In case you ever need to delete your app, here are the steps to clean up everything:\n\n")

      expect(removing_app_instructions[1]).to be_a(Instruction)
      expect(removing_app_instructions[1].type).to eq(:command)
      expect(removing_app_instructions[1].text).to eq("dokku proxy:clear-config #{app_name}")

      expect(removing_app_instructions[2]).to be_a(Instruction)
      expect(removing_app_instructions[2].type).to eq(:command)
      expect(removing_app_instructions[2].text).to eq("dokku apps:destroy #{app_name}")
    end
  end
end
