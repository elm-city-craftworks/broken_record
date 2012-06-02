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
        @table.update(:where  => { @table.primary_key => @key },
                      :fields => fields)
      else
        @table.insert(fields)
      end
    end

    def destroy
      @table.delete(@table.primary_key => @key)
    end

    # NOTE: I could potentially replace this with composite if it allowed for
    # finer grain control of when methods get dispatched. 
    #
    # Perhaps I want something like this:
    #
    #   features.append(@data) { |m, a, &b| @table.columns.key?(...) }
    #
    # But I'll leave this as a problem for later.
    def method_missing(m, *a, &b)
      return super unless @table.columns.key?(m[/(.*?)=?\z/,1].to_sym)
      
      @data.send(m, *a, &b)
    end
  end
end
