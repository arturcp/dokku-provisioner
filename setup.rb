# frozen_string_literal: true

require "dotenv/load"
require "pastel"
require "tty-prompt"
require "tty-font"

require_relative "models/dokku_provisioner.rb"

pastel = Pastel.new
divider = "======================================================================================="

provisioner = DokkuProvisioner.new

print "\e[2J\e[H"

font = TTY::Font.new(:starwars)
puts "#{pastel.yellow.bold(font.write("Dokku"))} \n"
puts "#{pastel.yellow.bold("===================================================")} \n"

puts "We are going to make some questions to help you setup your Dokku server. The sequence of questions may change depending on your answers,"
puts "and the final list of commands will be generated based on your answers."
puts ""
puts "Bear in mind that it is your reponsibility to understand the commands and select those that will need to run on your server. Feel free to"
puts "skip them. If you are not sure about something, please check the documentation at https://dokku.com/docs/getting-started/."
puts ""
puts "Press #{pastel.yellow.bold("ENTER")} to proceed..."
puts ""
gets.chomp

data = provisioner.provision

puts ""
data.instructions.keys.each do |key|
  if data.show_section?(key)
    title = key.to_s.gsub("_", " ").upcase
    formatted_title = pastel.cyan.bold(title)
    spaces_count = ((divider.length - title.length - 2).to_f / 2).ceil
    spaces = " " * spaces_count

    puts ""
    puts divider
    puts "|#{spaces}#{formatted_title}#{spaces}|\n"
    puts divider
    puts ""

    data.instructions[key].each do |instruction|
      provisioner.print_instruction(instruction)
    end
  end
end

puts ""
puts ""
