module BrokenRecord
  class TableMapper
    class Associations
      def initialize(mapper)
        self.mapper = mapper
      end

      def belongs_to(parent, params)
        mapper.record_class.send(:define_method, parent) do
          Object.const_get(params[:class]).find(send(params[:key]))
        end
      end

      def has_many(children, params)
        table_primary_key = mapper.primary_key

        mapper.record_class.send(:define_method, children) do
          Object.const_get(params[:class])
                .where(params[:key] => send(table_primary_key))
        end
      end

      def has_one(child, params)
        table_primary_key = mapper.primary_key

        mapper.record_class.send(:define_method, child) do
          Object.const_get(params[:class])
                .where(params[:key] => send(table_primary_key))
                .first
        end
      end

      private

      attr_accessor :mapper
    end
  end
end
