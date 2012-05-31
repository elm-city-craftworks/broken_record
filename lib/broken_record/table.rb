module BrokenRecord
  class Table
    def initialize(params)
      @name        = params.fetch(:name)
      @db          = params.fetch(:db)
      @columns     = {}

      parse_table_info
    end

    attr_reader :columns, :primary_key

    def insert(params)
      raise unless params.keys.all? { |e| columns.key?(e) }

      field_names = params.keys.join(", ")
      bind_vars   = (["?"] * params.count).join(", ")

      @db.execute %{
        insert into #{@db.class.quote(@name)} (#{field_names})
        values (#{bind_vars})
      }, params.values

      @db.get_first_value %{ select last_insert_rowid() }
    end

    def where(params)
      raise unless params.keys.all? { |e| columns.key?(e) }

      conds = params.map { |k,v| "#{@db.class.quote(k.to_s)} = ?" }.join(" AND ")

      raw_data = @db.execute %{
        select * from #{@db.class.quote(@name)}
        where #{conds}
      }, params.values

      raw_data.map { |row| Hash[columns.keys.zip(row)] }
    end

    private

    attr_reader :db
    attr_writer :primary_key

    def parse_table_info
      raw_data = @db.execute("PRAGMA table_info(#{@db.class.quote(@name)})")

      raw_data.each do |column|
        column_name = column[1].to_sym

        self.primary_key = column_name if column[-1] == 1
        columns[column[1].to_sym] = { :type => column[2] }
      end
    end
  end
end
