module BrokenRecord
  class RowBuilder
    def initialize(record_class)
      @record_class = record_class
      @fields       = []
    end

    def text(name)
      @fields << name
    end

    def integer(name)
      @fields << name
    end

    def build_row(table, row_data)
      @record_class.new(table, Hash[@fields.zip(row_data)])
    end
  end
end
