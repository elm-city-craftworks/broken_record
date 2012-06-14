module BrokenRecord
  class Relation
    class Associations
      def initialize(mapper)
        self.mapper = mapper
      end

      def belongs_to(parent, params)
        define_association(parent) do
          BrokenRecord.string_to_constant(params[:class])
                      .find(send(params[:key]))
        end
      end

      def has_many(children, params)
        table_primary_key = mapper.primary_key

        define_association(children) do
          BrokenRecord.string_to_constant(params[:class])
            .where(params[:key] => send(table_primary_key))
        end
      end

      def has_one(child, params)
        table_primary_key = mapper.primary_key

        define_association(child) do
          BrokenRecord.string_to_constant(params[:class])
            .where(params[:key] => send(table_primary_key)).first
        end
      end

      private

      def define_association(name, &block)
        mapper.record_class.send(:define_method, name, &block)
      end
      
      attr_accessor :mapper
    end
  end
end
