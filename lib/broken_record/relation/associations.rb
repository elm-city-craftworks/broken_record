module BrokenRecord
  class Relation
    class Associations
      def initialize(relation)
        self.relation = relation
      end

      def belongs_to(parent, params)
        relation.define_record_method(parent) do
          BrokenRecord.string_to_constant(params[:class])
                      .find(send(params[:key]))
        end
      end

      def has_many(children, params)
        table_primary_key = relation.table.primary_key

        relation.define_record_method(children) do
          BrokenRecord.string_to_constant(params[:class])
            .where(params[:key] => send(table_primary_key))
        end
      end

      def has_one(child, params)
        table_primary_key = relation.table.primary_key

        relation.define_record_method(child) do
          BrokenRecord.string_to_constant(params[:class])
            .where(params[:key] => send(table_primary_key)).first
        end
      end

      attr_accessor :relation
    end
  end
end
