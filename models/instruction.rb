# frozen_string_literal: true

class Instruction
  attr_reader :text, :type

  def self.command(text)
    new(:command, text)
  end

  def self.example(text)
    new(:example, text)
  end

  def self.information(text)
    new(:information, text)
  end

  def command?
    type == :command
  end

  def example?
    type == :example
  end

  def information?
    type == :information
  end

  private

  def initialize(type, text)
    @type = type
    @text = text
  end
end
