# frozen_string_literal: true

require_relative "../../../../models/provision_data"
require_relative "../../../../models/questionnaire/questions/server"
require "tty-prompt"

RSpec.describe Questionnaire::Questions::Server do
  let(:data) { ProvisionData.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:question) { described_class.new(data: data) }

  before do
    allow(question).to receive(:prompt).and_return(prompt)
  end

  describe "#ask" do
    context "when there are multiple servers" do
      it "prompts the user to choose a server and stores the answer in the data" do
        question.instance_variable_set(:@servers, ["Server1", "Server2"])
        expect(prompt).to receive(:select)
          .with("To which server are you going to deploy your app?", ["Server1", "Server2"])
          .and_return("Server1")

        question.ask

        expect(data.answers[:server]).to eq("Server1")
      end
    end

    context "when there is only one server" do
      it "sets the server answer to the only available server" do
        question.instance_variable_set(:@servers, ["Server1"])
        expect(prompt).not_to receive(:select)

        question.ask

        expect(data.answers[:server]).to eq("Server1")
      end
    end

    context "when there are no servers" do
      it "sets the server answer to the placeholder value" do
        question.instance_variable_set(:@servers, [])
        expect(prompt).not_to receive(:select)

        question.ask

        expect(data.answers[:server]).to eq("<HOSTNAME OR IP ADDRESS>")
      end
    end
  end

  describe "#setup_instructions" do
    it { expect(question.setup_instructions).to be_nil }
  end
end
