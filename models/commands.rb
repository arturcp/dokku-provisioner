# frozen_string_literal: true

class Commands
  def initialize(options = {})
    @app = options[:app]
    @domain = options[:domain]
    @env_vars = options[:env_vars]
    @postgresql = options[:postgresql]
    @redis = options[:redis]
    @ssl = options[:ssl]
  end

  def to_create_app
    commands = []

    commands << "dokku apps:create #{@app}"
    commands << "dokku git:initialize #{@app}"

    if @postgresql
      commands << "dokku postgres:create #{@app}-database"
      commands << "dokku postgres:link #{@app}-database #{@app}"
    end

    if @redis
      commands << "dokku redis:create #{@app}-redis"
      commands << "dokku redis:link #{@app}-redis #{@app}"
    end

    all_env_vars.each { |env_var_line| commands << env_var_line }

    commands << "dokku proxy:ports-set #{@app} http:80:5000"

    commands
  end

  def to_destroy_app
  end

  def all_env_vars
    @all_env_vars ||= begin
      env_vars.split("\n").map do |var|
        "dokku config:set --no-restart #{@app} #{var}"
      end
    end
  end
end
