# frozen_string_literal: true

require_relative "../../models/dokku_provisioner"
require_relative "../../models/questionnaire/question"

RSpec.describe DokkuProvisioner do
  let(:provisioner) { described_class.new }
  let(:eligible_question) do
    Class.new(Questionnaire::Question) do
      def ask; data.add_answer(:answer, 'answer'); end
      def setup_instructions; data.deploying_app << Instruction.command("command"); end
    end
  end

  let(:not_eligible_question) do
    Class.new(Questionnaire::Question) do
      def eligible?; false; end
      def ask; data.add_answer(:answer, 'invalid answer'); end
      def setup_instructions; data.deploying_app << Instruction.command("invalid command"); end
    end
  end

  before do
    stub_const "DokkuProvisioner::LIST_OF_QUESTIONS", [eligible_question, not_eligible_question]
  end

  describe "#provision" do
    it "does not ask questions that are not eligible" do
      expect_any_instance_of(not_eligible_question).not_to receive(:ask)

      provisioner.provision
    end

    it "asks questions that are eligible" do
      expect_any_instance_of(eligible_question).to receive(:ask)

      provisioner.provision
    end

    it "adds the answer to the data" do
      data = provisioner.provision
      expect(data.answers[:answer]).to eq('answer')
    end

    it "does not add the answer to the data if the question is not eligible" do
      data = provisioner.provision
      expect(data.answers[:answer]).not_to eq('invalid answer')
    end

    it "adds the setup instructions to the data" do
      data = provisioner.provision
      expect(data.deploying_app.last.text).to eq('command')
    end

    it "does not add the setup instructions to the data if the question is not eligible" do
      data = provisioner.provision
      expect(data.deploying_app.last.text).not_to eq('invalid command')
    end

    it "returns the data" do
      expect(provisioner.provision).to be_a(Data)
    end

    it "returns the data with the answers" do
      data = provisioner.provision
      expect(data.answers[:answer]).to eq('answer')
    end
  end

  describe "#print_instruction" do
    let(:information_instruction) { Instruction.information("This is an information instruction") }
    let(:command_instruction) { Instruction.command("This is a command instruction") }

    it "prints information instructions as is" do
      expect { provisioner.print_instruction(information_instruction) }
        .to output("This is an information instruction\n").to_stdout
    end

    it "prints command instructions with yellow color" do
      expect { provisioner.print_instruction(command_instruction) }
        .to output("\e[33mThis is a command instruction\e[0m\n").to_stdout
    end
  end
end
