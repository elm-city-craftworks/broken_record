require_relative "composable"

module BrokenRecord
  class TableMapper
    include Composable

    class CRUD
      def initialize(params)
        @table = Table.new(:name => params.fetch(:name),
                           :db   => BrokenRecord.database)

        @record_class = params.fetch(:record_class)
      end

      def create(params)
        id = @table.insert(params)    
      
        find(id)
      end

      def find(id)
        fields = @table.where(@table.primary_key => id).first

        return nil unless fields

        @record_class.new(:table => @table,
                         :fields => fields,
                         :key    => id)
      end

      def where(params)
        rows = @table.where(params)

        rows.map do |fields|
          @record_class.new(:table  => @table,
                            :fields => fields,
                            :key    => fields[@table.primary_key])
        end
      end

      def destroy(id)
        @table.delete(@table.primary_key => id)
      end

      def all
        # FIXME: USE PRIMARY KEY
        @table.all.map do |e| 
          @record_class.new(:table  => @table,
                            :fields => e,
                            :key    => e[@table.primary_key])
        end
      end
    end

    class Associations
      def initialize(params)
        @table = Table.new(:name => params.fetch(:name),
                            :db   => BrokenRecord.database)

        @record_class = params.fetch(:record_class)
      end

      def belongs_to(parent, params)
        @record_class.send(:define_method, parent) do
          Object.const_get(params[:class]).find(send(params[:key]))
        end
      end

      def has_many(children, params)
        @record_class.send(:define_method, children) do
          Object.const_get(params[:class])
                .where(params[:key] => send(table.primary_key))
        end
      end
    end

    def initialize(params)
      features << CRUD.new(params) << Associations.new(params)
    end
  end
end
