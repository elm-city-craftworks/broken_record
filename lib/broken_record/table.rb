module BrokenRecord
  class Table
    def initialize(params)
      @name        = params.fetch(:name)
      @db          = params.fetch(:db)
      @columns     = {}

      parse_table_info
    end

    attr_reader :columns

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

    def update(params)
      raise unless params[:where].keys.all?  { |e| columns.key?(e) }
      raise unless params[:fields].keys.all? { |e| columns.key?(e) }

      conds = params[:where].map { |k,v| "#{k.to_s} = ?" }
                            .join(" AND ")

      bind_vars = params[:fields].map { |k,v| "#{k}=?" }.join(", ")

      @db.execute %{
        update #{@name}
        set #{bind_vars}
        where #{conds}
      }, params[:fields].values + params[:where].values
    end

    def where(params)
      raise unless params.keys.all? { |e| columns.key?(e) }

      conds = params.map { |k,v| "#{@db.class.quote(k.to_s)} = ?" }
                    .join(" AND ")

      raw_data = @db.execute %{
        select * from #{@name}
        where #{conds}
      }, params.values

      raw_data.map { |row| Hash[columns.keys.zip(row)] }
    end

    def delete(params)
      raise unless params.keys.all? { |e| columns.key?(e) }

      conds = params.map { |k,v| "#{@db.class.quote(k.to_s)} = ?" }.join(" AND ")

      raw_data = @db.execute %{
        delete from #{@name}
        where #{conds}
      }, params.values
    end

    private

    attr_reader :db
    attr_writer :primary_key

    def parse_table_info
      raw_data = @db.execute("PRAGMA table_info(#{@name})")

      raw_data.each do |column|
        column_name = column[1].to_sym
        columns[column[1].to_sym] = { :type => column[2] }
      end
    end
  end
end
