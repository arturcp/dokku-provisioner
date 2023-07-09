# frozen_string_literal: true

require 'forwardable'

module Questionnaire
  class Question
    extend Forwardable

    attr_reader :answers, :config

    def_delegators :@config, :prompt, :pastel, :divider

    def initialize(answers:, config:)
      @answers = answers
      @config = config
    end

    def eligible?
      true
    end

    def variable_name
      self.class::VARIABLE_NAME
    end
  end
end
