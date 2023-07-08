# frozen_string_literal: true

require 'dotenv/load'
require "tty-prompt"
require "tty-spinner"

require_relative "models/dokku.rb"

pastel = Pastel.new
prompt = TTY::Prompt.new(active_color: :yellow, interrupt: :exit)

divider = "============================================================================\n\n"

app = prompt.ask("Name of the app:") { |q| q.required(true) }
domain = prompt.ask("Domain:") { |q| q.required(true) }

tools = [
  "Postgresql",
  "Redis"
]

selected_tools = prompt.multi_select("Choose the tools you will need", tools,
  per_page: tools.length, echo: false)

postgresql = selected_tools.include?("Postgresql")
redis = selected_tools.include?("Redis")

ssl = prompt.yes?("Do you need a SSL certificate?")

if ssl
  email = prompt.ask("SSL requires an email address:") { |q| q.required(true) }
end

puts ""
puts "Environment variables"
puts divider
puts ""
puts "You can paste all your env vars at once. Make sure they are one per line "
puts "and in the format KEY=value, like this:"
puts ""
puts "SITE_URL=https://my.site.com"
puts "SECRET_TOKEN=ABCD1234"
puts "WEBHOOK_URL=https://my.webhook.com/message"
puts ""

env_vars = prompt.multiline("Now, provide your environment variables:")

postgresql_backup = postgresql && prompt.yes?("Do you need to regularly backup your database?")

options = {
  app: app,
  domain: domain,
  email: email,
  env_vars: env_vars,
  postgresql: postgresql,
  redis: redis,
  ssl: ssl,
  postgresql_backup: postgresql_backup
}

instructions = Dokku.new(options).instructions

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

if ssl
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
