# frozen_string_literal: true

require_relative "questionnaire/questions/app_name"
require_relative "questionnaire/questions/domain"
require_relative "questionnaire/questions/tools"
require_relative "questionnaire/questions/postgresql_backup"
require_relative "questionnaire/questions/ssl"
require_relative "questionnaire/questions/ssl_email"
require_relative "questionnaire/questions/env_vars"

class Questions
  LIST_OF_QUESTIONS = [
    Questionnaire::Questions::AppName,
    Questionnaire::Questions::Domain,
    Questionnaire::Questions::Tools,
    Questionnaire::Questions::PostgresqlBackup,
    Questionnaire::Questions::SSL,
    Questionnaire::Questions::SSLEmail,
    Questionnaire::Questions::EnvVars
  ].freeze

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def pose
    LIST_OF_QUESTIONS.each_with_object({}) do |question, answers|
      question = question.new(answers: answers, config: config)

      next unless question.eligible?

      answer = question.ask
      answers.merge!(answer)
    end
  end
end
