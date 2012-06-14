module BrokenRecord
  class Relation
    class CRUD
      def initialize(relation)
        self.relation = relation
      end

      def create(values)
        raise unless record_class.new(:relation => relation,
                                      :values => values).valid?

        id = table.insert(values)    
      
        find(id)
      end

      def update(id, values)
        raise unless record_class.new(:relation => relation,
                                      :values   => values,
                                      :key      => id).valid?

        table.update(:where  => { table.primary_key => id },
                     :fields => values)
      end

      def find(id)
        values = table.where(table.primary_key => id).first

        return nil unless values

        record_class.new(:relation => relation,
                         :values   => values,
                         :key      => id)
      end

      def where(params)
        rows = table.where(params)

        rows.map do |values|
          record_class.new(:relation  => relation,
                           :values    => values,
                           :key       => values[table.primary_key])
        end
      end

      def destroy(id)
        table.delete(table.primary_key => id)
      end

      def all
        table.all.map do |values| 
          record_class.new(:relation  => relation,
                           :values    => values,
                           :key       => values[table.primary_key])
        end
      end

      private

      attr_accessor :relation

      def table
        relation.table
      end

      def record_class
        relation.record_class
      end
    end
  end
end
