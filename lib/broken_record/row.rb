module BrokenRecord
  class Row
    def initialize(params)
      @table  = params.fetch(:table)
      @key    = params.fetch(:key, nil)
      @fields = params.fetch(:fields, {})

      @data  = Struct.new(*@table.columns.keys).new

      @fields.each do |k,v|
        @data[k] = v
      end
    end

    def save
      fields = Hash[@data.members.zip(@data.values)]

      if @key
        # FIXME: should use primary key from Table
        @table.update(:where  => { :id => @key },
                      :fields => fields)
      else
        @table.insert(fields)
      end
    end

    def method_missing(m, *a, &b)
      return super unless @table.columns.key?(m[/(.*?)=?\z/,1].to_sym)
      
      @data.send(m, *a, &b)
    end
  end
end
