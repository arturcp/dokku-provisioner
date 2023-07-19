# frozen_string_literal: true

class Dokku
  def initialize(options = {})
    @app = options[:app].to_s.downcase.gsub(" ", "-")
    @domain = options[:domain]
    @env_vars = Array(options[:env_vars]).map(&:chomp)
    @postgresql = options[:postgresql]
    @redis = options[:redis]
    @ssl = options[:ssl]
    @email = options[:email]
  end

  def instructions
    {
      after_deploy: after_deploy_instructions,
      create: create_app_instructions,
      deploy: deploy_instructions,
      destroy: destroy_app_instructions,
      ssl: ssl_instructions
    }
  end

  private

  def after_deploy_instructions
    return [] unless @redis

    [
      "dokku ps:scale #{@app} worker=1"
    ]
  end

  def create_app_instructions
    commands = []

    commands << "dokku apps:create #{@app}"
    commands << "dokku git:initialize #{@app}"

    if @postgresql
      commands << "dokku plugin:install https://github.com/dokku/dokku-postgres.git"
      commands << "dokku postgres:create #{@app}-database"
      commands << "dokku postgres:link #{@app}-database #{@app}"
    end

    if @redis
      commands << "dokku plugin:install https://github.com/dokku/dokku-redis.git redis"
      commands << "dokku redis:create #{@app}-redis"
      commands << "dokku redis:link #{@app}-redis #{@app}"
    end

    @env_vars.each do |var|
      commands << "dokku config:set --no-restart #{@app} #{var.strip.chomp}"
    end

    commands << "dokku domains:add #{@app} #{@domain}" if @domain && !@domain.empty?
    commands << "dokku proxy:ports-set #{@app} http:80:5000"

    commands
  end

  def deploy_instructions
    [
      "git remote add dokku dokku@#{dokku_ip_address}:#{@app}"
    ]
  end

  def destroy_app_instructions
    commands = []

    if @postgresql
      commands << "dokku postgres:unlink #{@app}-database #{@app}"
      commands << "dokku postgres:destroy #{@app}-database"
    end

    if @redis
      commands << "dokku redis:unlink #{@app}-redis #{@app}"
      commands << "dokku redis:destroy #{@app}-redis"
    end

    commands << "dokku proxy:clear-config #{@app}"
    commands << "dokku apps:destroy #{@app}"

    commands
  end

  def ssl_instructions
    commands = []

    commands << "dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git"
    commands << "dokku letsencrypt:set #{@app} email #{@email}"
    commands << "dokku letsencrypt:enable #{@app}"
    commands << "dokku letsencrypt:cron-job --add"

    commands
  end

  def all_env_vars
    @all_env_vars ||= begin
      @env_vars.map do |var|
        "dokku config:set --no-restart #{@app} #{var.strip.chomp}"
      end
    end
  end

  def dokku_ip_address
    ENV.fetch("DOKKU_IP_ADDRESS", "<IP ADDRESS>")
  end
end
