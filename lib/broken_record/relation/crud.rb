module BrokenRecord
  class Relation
    class CRUD
      def initialize(relation)
        self.relation = relation
      end

      def create(values)
        id = table.insert(values)    
      
        find(id)
      end

      def update(id, values)
        table.update(:where  => { table.primary_key => id },
                     :fields => values)
      end

      def find(id)
        values = table.where(table.primary_key => id).first

        return nil unless values

        relation.new_record(values)
      end

      def where(params)
        rows = table.where(params)

        rows.map do |values|
          relation.new_record(values)
        end
      end

      def destroy(id)
        table.delete(table.primary_key => id)
      end

      def all
        table.all.map { |values| relation.new_record(values) }
      end

      private

      attr_accessor :relation

      def table
        relation.table
      end
    end
  end
end
