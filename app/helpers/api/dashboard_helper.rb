module Api::DashboardHelper
  def count_all_tables(which_db)
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
