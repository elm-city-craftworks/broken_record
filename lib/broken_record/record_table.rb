module BrokenRecord
  class RecordTable
    def initialize(record_class, table_name, &block)
      @table_name  = table_name
      @row_builder = RowBuilder.new(record_class)

      SimpleDelegator.new(self).instance_eval(&block)
    end

    def columns(&block)
      SimpleDelegator.new(@row_builder).instance_eval(&block)
    end

    def create(params)
      escapes = params.count.times.map { "?" }.join(", ") 
      fields  = params.keys.join(", ")

      BrokenRecord.database.execute(
        "insert into #{@table_name} (#{fields}) values (#{escapes})",
        params.values
      )
    end

    def destroy(id)
      BrokenRecord.database.execute(
        "delete from #{@table_name} where id = ?",
        [id]
      )
    end

    def update(id, params)
      # FIXME: This is probably not secure
      sql = params.map { |k,v| "#{k} = #{v.inspect}" }.join(", ")

      BrokenRecord.database.execute %{
        update #{@table_name}
        set #{sql}
        where id = #{id}
      }
    end

    def all
      BrokenRecord.database.execute( "select * from #{@table_name}" )
                           .map { |r| @row_builder.build_row(self, r) }
    end

    # FIXME: Blech!
    def find(id)
      BrokenRecord.database.execute( "select * from #{@table_name} where id = ?", [id] )
                           .map { |r| @row_builder.build_row(self, r) }.first
    end
  end
end
