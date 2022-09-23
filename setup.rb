# frozen_string_literal: true

require 'dotenv/load'
require "tty-prompt"
require "tty-spinner"

require_relative "models/dokku.rb"

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

env_vars = prompt.multiline("Now, provide your environment variables:")

options = {
  app: app,
  domain: domain,
  postgresql: postgresql,
  redis: redis,
  https: https,
  env_vars: env_vars
}

instructions = Dokku.new(options).instructions

puts ""
puts "#{pastel.yellow.bold("TO CREATE YOUR APP")} \n"
puts "==================================================\n"
puts instructions[:create].join("\n")

puts ""
puts "#{pastel.yellow.bold("TO DEPLOY YOUR APP")} \n"
puts "==================================================\n"
puts instructions[:deploy].join("\n")

if (instructions[:after_deploy].length > 0)
  puts ""
  puts "#{pastel.yellow.bold("AFTER THE DEPLOY")} \n"
  puts "==================================================\n"
  puts instructions[:after_deploy].join("\n")
end

if (instructions[:ssl].length > 0)
  puts ""
  puts "#{pastel.yellow.bold("SSL INSTRUCTIONS")} \n"
  puts "==================================================\n"
  puts instructions[:ssl].join("\n")
end

puts ""
puts "#{pastel.yellow.bold("TO REMOVE YOUR APP")} \n"
puts "==================================================\n"
puts instructions[:destroy].join("\n")
