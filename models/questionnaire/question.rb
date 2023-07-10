# frozen_string_literal: true

require 'forwardable'

module Questionnaire
  class Question
    extend Forwardable

    attr_reader :data

    def initialize(data:)
      @data = data
    end

    def eligible?
      true
    end

    private

    def pastel
      @pastel ||= Pastel.new
    end

    def prompt
      @prompt ||= TTY::Prompt.new(active_color: :yellow, interrupt: :exit,
        prefix: pastel.cyan("[?] "))
    end
  end
end
