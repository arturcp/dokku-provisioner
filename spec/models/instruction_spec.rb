# frozen_string_literal: true

require_relative "../../models/instruction"

RSpec.describe Instruction do
  describe ".command" do
    it "creates a new instruction with type :command" do
      text = "Do something"
      instruction = described_class.command(text)

      expect(instruction.type).to eq(:command)
      expect(instruction.text).to eq(text)
    end
  end

  describe ".example" do
    it "creates a new instruction with type :example" do
      text = "Example instruction"
      instruction = described_class.example(text)

      expect(instruction.type).to eq(:example)
      expect(instruction.text).to eq(text)
    end
  end

  describe ".information" do
    it "creates a new instruction with type :information" do
      text = "Informational instruction"
      instruction = described_class.information(text)

      expect(instruction.type).to eq(:information)
      expect(instruction.text).to eq(text)
    end
  end

  describe "#command?" do
    it "returns true if the instruction type is :command" do
      instruction = described_class.new(:command, "Do something")
      expect(instruction.command?).to be true
    end

    it "returns false if the instruction type is not :command" do
      instruction = described_class.new(:example, "Example instruction")
      expect(instruction.command?).to be false
    end
  end

  describe "#example?" do
    it "returns true if the instruction type is :example" do
      instruction = described_class.new(:example, "Example instruction")
      expect(instruction.example?).to be true
    end

    it "returns false if the instruction type is not :example" do
      instruction = described_class.new(:information, "Informational instruction")
      expect(instruction.example?).to be false
    end
  end

  describe "#information?" do
    it "returns true if the instruction type is :information" do
      instruction = described_class.new(:information, "Informational instruction")
      expect(instruction.information?).to be true
    end

    it "returns false if the instruction type is not :information" do
      instruction = described_class.new(:example, "Example instruction")
      expect(instruction.information?).to be false
    end
  end
end
