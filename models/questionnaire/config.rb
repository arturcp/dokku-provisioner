# frozen_string_literal: true

module Questionnaire
  class Config
    DEFAULT_PASTEL = Pastel.new.freeze
    DEFAULT_PROMPT = TTY::Prompt.new(active_color: :yellow, interrupt: :exit).freeze

    attr_reader :divider, :pastel, :prompt

    def initialize(divider: "", pastel: DEFAULT_PASTEL, prompt: DEFAULT_PROMPT)
      @divider = divider
      @pastel = pastel
      @prompt = prompt
    end
  end
end
