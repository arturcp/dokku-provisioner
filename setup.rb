# frozen_string_literal: true

require "tty-prompt"
require "tty-spinner"

require_relative "models/commands.rb"

pastel = Pastel.new
prompt = TTY::Prompt.new(active_color: :yellow, interrupt: :exit)

app = prompt.ask("Name of the app:") { |q| q.required true }
domain = prompt.ask("Domain:") { |q| q.required true }

tools = [
  "Postgresql",
  "Redis"
]

selected_tools = prompt.multi_select("Choose the tools you will need", tools,
  per_page: tools.length, echo: false)

postgresql = selected_tools.include?("Postgresql")
redis = selected_tools.include?("Redis")

https = prompt.yes?("Do you need a SSL certificate?")

puts ""
puts "Environment variables"
puts "======================"
puts ""
puts "You can paste all your env vars at once. Make sure they are one per line "
puts "and in the format KEY=value, like this:"
puts ""
puts "SITE_URL=https://my.site.com"
puts "SECRET_TOKEN=ABCD1234"
puts "WEBHOOK_URL=https://my.webhook.com/message"
puts ""
env_vars = prompt.ask("Now, provide your environment variables:")

options = {
  app:,
  domain:,
  postgresql:,
  redis:,
  https:,
  env_vars:
}

commands = Commands.new(options)

puts ""
puts "#{pastel.yellow.bold("LIST OF COMMANDS TO CREATE YOUR APP")} \n\n"
puts commands.to_create_app.join("\n")

puts ""
puts "#{pastel.yellow.bold("LIST OF COMMANDS TO REMOVE YOUR APP")} \n\n"
puts commands.to_remove_app.join("\n")
