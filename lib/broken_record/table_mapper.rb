module BrokenRecord
  class TableMapper
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
      fields = @table.where(:id => id).first

      return nil unless fields

      # FIXME: USE PRIMARY KEY
      @record_class.new(:table => @table,
                       :fields => fields,
                       :key    => id)
    end

    def destroy(id)
      # FIXME: USE PRIMARY KEY
      @table.delete(:id => id)
    end

    def all
      # FIXME: USE PRIMARY KEY
      @table.all.map do |e| 
        @record_class.new(:table  => @table,
                          :fields => e,
                          :key    => e[:id])
      end
    end
  end
end
