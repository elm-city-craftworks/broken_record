module BrokenRecord
  class Table
    def initialize(params)
      @name        = params.fetch(:name)
      @db          = params.fetch(:db)
      @columns     = {}

      parse_table_info
    end

    attr_reader :columns, :primary_key, :name

    def insert(params)
      raise unless params.keys.all? { |e| columns.key?(e) }

      field_names = params.keys.join(", ")
      bind_vars   = (["?"] * params.count).join(", ")

      db.execute %{
        insert into #{name} (#{field_names}) values (#{bind_vars})
      }, params.values

      db.get_first_value %{ select last_insert_rowid() }
    end

    def update(params)
      db.execute %{
        update #{name}
        set #{bind_vars(params[:fields], ", ")}
        where #{bind_vars(params[:where], " AND ")}
      }, params[:fields].values + params[:where].values
    end

    def where(params)
      raw_data = db.execute %{
        select * from #{name}
        where #{bind_vars(params, " AND ")}
      }, params.values

      raw_data.map { |row| Hash[columns.keys.zip(row)] }
    end

    def all
      raw_data = db.execute %{ select * from #{name} }

      raw_data.map { |row| Hash[columns.keys.zip(row)] }
    end

    def delete(params)
      db.execute %{
        delete from #{name}
        where #{bind_vars(params, " AND ")}
      }, params.values
    end

    private

    attr_reader :db
    attr_writer :primary_key

    def bind_vars(params, separator)
      raise unless params.keys.all? { |e| columns.key?(e) }

      params.map { |k,v| "#{k} = ?" }.join(separator)
    end

    def parse_table_info
      raw_data = @db.execute("PRAGMA table_info(#{name})")

      raw_data.each do |column|
        column_name = column[1].to_sym

        self.primary_key = column_name if column[-1] == 1

        columns[column[1].to_sym] = { :type => column[2] }
      end
    end
  end
end
