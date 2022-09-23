# frozen_string_literal: true

class Dokku
  def initialize(options = {})
    @app = options[:app].to_s.downcase
    @domain = options[:domain]
    @env_vars = Array(options[:env_vars]).map(&:chomp)
    @postgresql = options[:postgresql]
    @redis = options[:redis]
    @ssl = options[:ssl]
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
    []
  end

  def create_app_instructions
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
    []
  end

  def ssl_instructions
    []
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
