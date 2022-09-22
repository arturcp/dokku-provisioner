# frozen_string_literal: true

require "tty-prompt"
require "tty-spinner"

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

https = prompt.yes?("Do you need a SSL certificate?")
