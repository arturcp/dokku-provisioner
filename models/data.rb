# frozen_string_literal: true

require_relative "instruction"

class Data
  attr_reader :answers, :instructions

  def initialize
    @answers = {}

    @instructions = {
      prerequisites: [
        Instruction.information("There are some steps you may need to take before setting up your app, like adding"),
        Instruction.information("necessary plugins. You do not need to do these steps if you have already done them, "),
        Instruction.information("but if you run the commands again, it will not hurt anything.\n\n"),
        Instruction.information("Before setting up your app, make sure you have dokku installed on your server. Now, "),
        Instruction.information("run the following commands on your server:\n\n")
      ],
      creating_app: [],
      database: [
        Instruction.information("When attaching a database to your app, you need to choose a name for it. To simplify"),
        Instruction.information("your live and the future maintenance of your apps, we are going to use the name of "),
        Instruction.information("your app with the suffix '-database'. For example, if your app is called 'my-app', "),
        Instruction.information("your database will be called 'my-app-database'.\n\n"),
        Instruction.information("Now, run the following commands on your server:\n\n")
      ],
      redis: [
        Instruction.information("When using redis in your app, you need to choose a name for it. To simplify your"),
        Instruction.information("life and the future maintenance of your apps, we are going to use the name of your"),
        Instruction.information("app with the suffix '-redis'. For example, if your app is called 'my-app', your redis"),
        Instruction.information("instance will be called 'my-app-redis'.\n\n"),
        Instruction.information("Now, run the following commands on your server:\n\n")
      ],
      ssl: [
        Instruction.information("To allow users to access your app using http, you need to configure SSL. To do so,"),
        Instruction.information("you need to follow these steps:\n\n")
      ],
      deploying_app: [
        Instruction.information("You need to set up your local git config to point to a dokku remote.\n\n")
      ],
      removing_app: [
        Instruction.information("In case you ever need to delete your app, here are the steps to clean up everything:\n\n")
      ]
    }
  end

  def add_answer(key, value)
    @answers[key] = value
  end

  def creating_app
    @instructions[:creating_app]
  end

  def database
    @instructions[:database]
  end

  def deploying_app
    @instructions[:deploying_app]
  end

  def prerequisite
    @instructions[:prerequisites]
  end

  def redis
    @instructions[:redis]
  end

  def removing_app
    @instructions[:removing_app]
  end

  def show_section?(section)
    @instructions[section].any? { |instruction| instruction.command? }
  end

  def ssl
    @instructions[:ssl]
  end
end
