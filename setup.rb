# frozen_string_literal: true

require "dotenv/load"
require "tty-prompt"
require "tty-spinner"
require "tty-font"

require_relative "models/dokku_provisioner.rb"
require_relative "models/questions.rb"
require_relative "models/questionnaire/config.rb"

pastel = Pastel.new
prompt = TTY::Prompt.new(active_color: :yellow, interrupt: :exit, prefix: pastel.cyan("[?] "))
divider = "===================================================\n\n"

config = Questionnaire::Config.new(divider: divider, pastel: pastel, prompt: prompt)
questions = Questions.new(config)

print "\e[2J\e[H"

font = TTY::Font.new(:starwars)
puts "#{pastel.yellow.bold(font.write("Dokku"))} \n"
puts "#{pastel.yellow.bold(divider)} \n"

puts "We are going to make some questions to help you setup your Dokku server. The sequence of questions may change depending on your answers,"
puts "and the final list of commands will be generated based on your answers."
puts ""
puts "Bear in mind that it is your reponsibility to understand the commands and select those that will need to run on your server. Feel free to"
puts "skip them. If you are not sure about something, please check the documentation at https://dokku.com/docs/getting-started/."
puts ""
puts "Press #{pastel.yellow.bold("ENTER")} to proceed..."
puts ""
gets.chomp

answers = questions.pose_all
instructions = DokkuProvisioner.new(answers).instructions

puts ""
puts ""
puts ""
puts "#{pastel.yellow.bold("TO CREATE YOUR APP")} \n"
puts divider
puts pastel.yellow(instructions[:create].join("\n"))

if instructions[:postgresql_backup].length > 0
  puts ""
  puts "You will need to run these commands to setup the backup of your database:"
  puts ""
  puts pastel.yellow(instructions[:postgresql_backup].join("\n"))
end

deploy_instructions = instructions[:deploy].join("\n")
puts ""
puts "#{pastel.yellow.bold("TO DEPLOY YOUR APP")} \n"
puts divider
puts "You need to set up your local git config to point to a dokku remote."
puts "If you do not have one setup, go to your project and run:"
puts ""
puts pastel.yellow(deploy_instructions)
puts ""
puts "If you do and need to change the remote url, run this instead:"
puts ""
puts pastel.yellow(deploy_instructions.gsub("remote add", "remote set-url"))

if instructions[:after_deploy].length > 0
  puts ""
  puts "#{pastel.yellow.bold("AFTER THE DEPLOY")} \n"
  puts divider
  puts "Once your code is on Dokku, you can run these commands:"
  puts ""
  puts pastel.yellow(instructions[:after_deploy].join("\n"))
end

if answers[:ssl]
  puts ""
  puts "#{pastel.yellow.bold("SSL INSTRUCTIONS")} \n"
  puts divider
  puts "Execute these commands only after your app is up and running without SSL."
  puts "If you try to use them before that, Letsencrypt will fail to reach it."
  puts ""
  puts pastel.yellow(instructions[:ssl].join("\n"))
end

puts ""
puts "#{pastel.yellow.bold("TO REMOVE YOUR APP")} \n"
puts divider
puts "Some of the next instructions wait for a Y/N confirmation."
puts "We highly recommend that you run one at a time:"
puts ""
puts pastel.yellow(instructions[:destroy].join("\n"))
