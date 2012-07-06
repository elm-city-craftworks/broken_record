require "mozart"

module BrokenRecord
  class Relation
    class Associations
      include Mozart::SingleAssignment

      def initialize(relation)
        _(:relation, relation)
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

      private

      def relation
        _(:relation)
      end
    end
  end
end
