class DbClient
  LOG_SQL = true

  class << self
    # exec by ActiveRecord
    def primary_exec(options = {}, &block)
      config = { role: :writing, prevent_writes: false }
      config.merge!(options) if options.present?
      _db_execute(config) do
        yield
      end
    end

    def primary_replica_exec(options = {}, &block)
      config = { role: :reading }
      config.merge!(options) if options.present?
      config[:prevent_writes] = true # disable writes on salve db
      _db_execute(config) do
        yield
      end
    end

    def _db_execute(config = {}, &block)
      begin
        ActiveRecord::Base.connected_to(config) do
          yield
        end
        [true, nil]
      rescue StandardError => e
        err_msg = "#{config} DB error: #{e.inspect}"
        self.log_by(:error, err_msg)
        if e.is_a? Mysql2::Error
          raise e
        end
        [false, e]
      end
    end

    # custom logger
    def logger
      return @logger if @logger.present?
      @logger = Logger.new('log/db_execute.log')
      @logger.formatter = proc do |severity, datetime, progname, msg|
        msg.size < 8 ? "#{msg}" : "\n#{severity.upcase}: #{msg}"
      end
      @logger
    end

    def log_sql(level, msg)
      self.log_by(level, msg) if self::LOG_SQL
    end

    def log_by(level, msg)
      if msg.size < 8
        print msg
      else
        puts "\n#{level.upcase}: #{msg}"
      end
      self.logger.send(level, msg)
    end
  end
end

