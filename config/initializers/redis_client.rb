class RedisClient
  class << self
    def current
      @client ||= Redis.new(config)
    end

    def config
      {
        host: ENV['REDIS_HOST'] || '127.0.0.1',
        port: ENV['REDIS_PORT'] || '6379',
        password: ENV['REDIS_PASS'],
        db: 1,
        namespace: 'master-slave-demo',
        expires_in: 10.minutes
      }.select {|k, v| v.present?}
    end
  end
end
