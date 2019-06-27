require "octokit"
require "y2dev/github/repository"

module Y2Dev
  class Github
    def self.login(token: nil)
      login_options = login_options(token)

      raise("GitHub token is not set") if login_options.nil?

      new(login_options)
    end

    attr_reader :client

    def repositories
      client.repositories.map { |r| Repository.new(client, r) }
    end

  private

    CONFIG_FILE = File.join(Dir.home, ".netrc").freeze

    def self.login_options(token)
      if token
        { access_token: token }
      elsif config_file?
        { netrc: true }
      end
    end

    def self.config_file?
      File.exist?(CONFIG_FILE) && File.read(CONFIG_FILE).match(/^machine api.github.com/)
    end

    def initialize(login_options)
      @client = Octokit::Client.new(login_options)
      @client.auto_paginate = true
    end
  end
end