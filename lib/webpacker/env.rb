class Webpacker::Env
  DEFAULT = "production".freeze

  delegate :config_path, :logger, to: :@webpacker

  def self.inquire(webpacker)
    new(webpacker).inquire
  end

  def initialize(webpacker)
    @webpacker = webpacker
  end

  def inquire
    fallback_env_warning if config_path.exist? && !current
    current || DEFAULT.inquiry
  end

  private
    def current
      Jets.env.presence_in(available_environments)
    end

    def fallback_env_warning
      logger.info "JETS_ENV=#{Jets.env} environment is not defined in config/webpacker.yml, falling back to #{DEFAULT} environment"
    end

    def available_environments
      if config_path.exist?
        begin
          YAML.load_file(config_path.to_s, aliases: true)
        rescue ArgumentError
          YAML.load_file(config_path.to_s)
        end
      else
        [].freeze
      end
    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{config_path}. " \
            "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
            "Error: #{e.message}"
    end
end
