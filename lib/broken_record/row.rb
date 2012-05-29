module BrokenRecord
  class Row
    def initialize(table, params)
      @table = table
      @data  = Struct.new(*params.keys.map(&:to_sym)).new(*params.values)
    end

    def save
      params = Hash[@data.each_pair.to_a]
      id     = params.delete(:id)

      @table.update(id, params)
    end

    def method_missing(m, *a, &b)
      @data.public_send(m, *a, &b)
    end
  end
end
