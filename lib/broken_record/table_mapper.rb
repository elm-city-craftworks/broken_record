require_relative "composable"

module BrokenRecord
  class TableMapper
    include Composable

    def initialize(params)
      @table = Table.new(:name => params.fetch(:name),
                         :db   => BrokenRecord.database)

      @record_class = params.fetch(:record_class)

      features << CRUD.new(self) << Associations.new(self)
    end

    attr_reader :table, :record_class

    def column_names
      @table.columns.keys
    end

    def primary_key
      @table.primary_key
    end

    class CRUD
      def initialize(mapper)
        @mapper       = mapper
      end

      def create(params)
        raise unless record_class.new(:mapper => mapper,
                                      :fields => params).valid?

        id = table.insert(params)    
      
        find(id)
      end

      def update(id, params)
        raise unless record_class.new(:mapper => mapper,
                                      :fields => params,
                                      :key    => id).valid?

        table.update(:where  => { table.primary_key => id },
                     :fields => params)
      end

      def find(id)
        fields = table.where(table.primary_key => id).first

        return nil unless fields

        record_class.new(:mapper => mapper,
                         :fields => fields,
                         :key    => id)
      end

      def where(params)
        rows = table.where(params)

        rows.map do |fields|
          record_class.new(:mapper  => mapper,
                           :fields  => fields,
                           :key     => fields[table.primary_key])
        end
      end

      def destroy(id)
        table.delete(table.primary_key => id)
      end

      def all
        table.all.map do |e| 
          record_class.new(:mapper  => mapper,
                           :fields  => e,
                           :key     => e[table.primary_key])
        end
      end

      private

      attr_reader :mapper

      def table
        mapper.table
      end

      def record_class
        mapper.record_class
      end
    end

    class Associations
      def initialize(mapper)
        @mapper = mapper
      end

      def belongs_to(parent, params)
        @mapper.record_class.send(:define_method, parent) do
          Object.const_get(params[:class]).find(send(params[:key]))
        end
      end

      def has_many(children, params)
        table_primary_key = @mapper.primary_key

        @mapper.record_class.send(:define_method, children) do
          Object.const_get(params[:class])
                .where(params[:key] => send(table_primary_key))
        end
      end

      def has_one(child, params)
        table_primary_key = @mapper.primary_key

        @mapper.record_class.send(:define_method, child) do
          Object.const_get(params[:class])
                .where(params[:key] => send(table_primary_key))
                .first
        end
      end
    end
  end
end
