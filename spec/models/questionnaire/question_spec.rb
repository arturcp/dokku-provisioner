# frozen_string_literal: true

require_relative "../../../models/data"
require_relative "../../../models/questionnaire/question"

RSpec.describe Questionnaire::Question do
  let(:data) { instance_double(Data) }

  describe "#initialize" do
    it "sets the data attribute" do
      question = described_class.new(data: data)
      expect(question.data).to eq(data)
    end
  end

  describe "#eligible?" do
    it "returns true by default" do
      question = described_class.new(data: data)
      expect(question.eligible?).to eq(true)
    end
  end
end
