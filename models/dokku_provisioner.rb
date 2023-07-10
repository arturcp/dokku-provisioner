# frozen_string_literal: true

require "pastel"
require "tty-prompt"


require_relative "data"
require_relative "questionnaire/questions/app_name"
require_relative "questionnaire/questions/domain"
require_relative "questionnaire/questions/env_vars"
require_relative "questionnaire/questions/final_question"
require_relative "questionnaire/questions/postgresql_backup"
require_relative "questionnaire/questions/ssl"
require_relative "questionnaire/questions/tools"

class DokkuProvisioner
  LIST_OF_QUESTIONS = [
    Questionnaire::Questions::AppName,
    Questionnaire::Questions::Domain,
    Questionnaire::Questions::Tools,
    Questionnaire::Questions::PostgresqlBackup,
    Questionnaire::Questions::SSL,
    Questionnaire::Questions::EnvVars,
    Questionnaire::Questions::FinalQuestion
  ].freeze

  def provision
    Data.new.tap do |data|
      LIST_OF_QUESTIONS.each do |question|
        question = question.new(data: data)

        next unless question.eligible?

        question.ask
        question.setup_instructions
      end
    end
  end

  def print_instruction(instruction)
    if instruction.information?
      puts instruction.text
    else
      puts pastel.yellow(instruction.text)
    end
  end

  private

  def pastel
    @pastel ||= Pastel.new
  end
end
