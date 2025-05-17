# frozen_string_literal: true

require_relative "../../models/provision_data"
require_relative "../../models/instruction"

RSpec.describe ProvisionData do
  let(:data) { described_class.new }

  describe "#add_answer" do
    it "adds an answer to the answers hash" do
      data.add_answer(:question1, "Answer 1")
      expect(data.answers[:question1]).to eq("Answer 1")
    end
  end

  describe "#creating_app" do
    it "returns the instructions for creating the app" do
      instructions = data.creating_app
      expect(instructions).to be_an(Array)
      expect(instructions).to be_empty
    end
  end

  describe "#database" do
    it "returns the instructions for setting up the database" do
      instructions = data.database
      expect(instructions).to be_an(Array)
      expect(instructions).not_to be_empty
    end
  end

  describe "#deploying_app" do
    it "returns the instructions for deploying the app" do
      instructions = data.deploying_app
      expect(instructions).to be_an(Array)
      expect(instructions).not_to be_empty
    end
  end

  describe "#prerequisite" do
    it "returns the prerequisite instructions" do
      instructions = data.prerequisites
      expect(instructions).to be_an(Array)
      expect(instructions).not_to be_empty
    end
  end

  describe "#redis" do
    it "returns the instructions for setting up Redis" do
      instructions = data.redis
      expect(instructions).to be_an(Array)
      expect(instructions).not_to be_empty
    end
  end

  describe "#removing_app" do
    it "returns the instructions for removing the app" do
      instructions = data.removing_app
      expect(instructions).to be_an(Array)
      expect(instructions).not_to be_empty
    end
  end

  describe "#show_section?" do
    it "returns true if the section contains command instructions" do
      expect(data.show_section?(:creating_app)).to be false

      data.creating_app << Instruction.command("dokku apps:create my-app")

      expect(data.show_section?(:creating_app)).to be true
    end
  end

  describe "#ssl" do
    it "returns the instructions for configuring SSL" do
      instructions = data.ssl
      expect(instructions).to be_an(Array)
      expect(instructions).not_to be_empty
    end
  end
end
