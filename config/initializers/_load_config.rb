REDIS_CONFIG = YAML.load(ERB.new(File.new("#{Rails.root}/config/redis.yml").read).result)

