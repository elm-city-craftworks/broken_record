module BrokenRecord
  class Table
    def initialize(record_class, table_name, &block)
      @table_name  = table_name
      @row_builder = RowBuilder.new(record_class)

      SimpleDelegator.new(self).instance_eval(&block)
    end

    def columns(&block)
      SimpleDelegator.new(@row_builder).instance_eval(&block)
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
      BrokenRecord.database.query( "select * from #{@table_name}" ) do |results|
        return results.map { |r| @row_builder.build_row(self, r) }
      end
    end

    # FIXME: Blech!
    def find(id)
      BrokenRecord.database.query( "select * from #{@table_name} where id = ?", [id] ) do |results|
        return results.map { |r| @row_builder.build_row(self, r) }.first
      end
    end
  end
end
