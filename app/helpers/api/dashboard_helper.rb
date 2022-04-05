module Api::DashboardHelper
  def fetch_all_count_cache(which_db)
    time_data = count_all_tables(which_db)
    redis_key = time_data.keys.first.to_s

    exist_data = RedisClient.current.hgetall(which_db)
    if exist_data[redis_key].blank?
      RedisClient.current.hset(which_db, redis_key, time_data.values.first.to_json)
    else
    end

    new_data = {}
    data_index = 0
    recent_size = 15
    exist_data = RedisClient.current.hgetall(which_db)
    data_start_index = exist_data.size - recent_size

    exist_data.each {|k, v|
      begin
        if data_index >= data_start_index
          new_data[k] = JSON.parse(v)
        end
        data_index += 1
      rescue JSON::ParserError => e
        puts "ParserError: #{e.inspect}"
      end
    }
    if new_data.size < recent_size
      puts "#{which_db} -> cached time data, #{new_data.size} count"
    end
    new_data
  end

  def count_all_tables(which_db)
    which_db = :primary_replica if which_db == :replica
    data = {}
    start_time = Time.now
    start_timef = start_time.to_f.round(2)
    start_key = start_time.to_i

    unless data.key?(start_key)
      data[start_key] = {}
      data[start_key][:start_timef] = start_timef
    end

    # data = data_by_base_conn(which_db, data, start_key)
    %w(User Product Order).each do |model_name|
      DbClient.send("#{which_db}_exec") do
        row_count = class_eval(model_name.to_s).count(:id)
        data_key = "#{model_name}Count"
        data[start_key][data_key] = row_count
      end
    end
    data
  end

  def data_by_base_conn(which_db, data, start_key)
    db_config = Rails.application.config.database_configuration[Rails.env]['primary']
    DbClient.send("#{which_db}_exec") do
      db_result = ActiveRecord::Base.connection.execute("SELECT TABLE_NAME, TABLE_ROWS FROM `information_schema`.`tables` WHERE `table_schema` = '#{db_config['database']}'").to_h
      %w(users products orders).each do |model_name|
        if db_result.key?(model_name.to_s)
          data_key = "#{model_name}Count"
          data[start_key][data_key] = db_result[model_name.to_s]
        end
      end
    end
    data
  end
end
