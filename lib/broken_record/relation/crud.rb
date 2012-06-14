module BrokenRecord
  class Relation
    class CRUD
      def initialize(mapper)
        self.mapper = mapper
      end

      def create(fields)
        raise unless record_class.new(:mapper => mapper,
                                      :fields => fields).valid?

        id = table.insert(fields)    
      
        find(id)
      end

      def update(id, fields)
        raise unless record_class.new(:mapper => mapper,
                                      :fields => fields,
                                      :key    => id).valid?

        table.update(:where  => { table.primary_key => id },
                     :fields => fields)
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
        table.all.map do |fields| 
          record_class.new(:mapper  => mapper,
                           :fields  => fields,
                           :key     => fields[table.primary_key])
        end
      end

      private

      attr_accessor :mapper

      def table
        mapper.table
      end

      def record_class
        mapper.record_class
      end
    end
  end
end
