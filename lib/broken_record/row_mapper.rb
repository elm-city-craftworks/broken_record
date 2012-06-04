require_relative "composable"
require_relative "row"

module BrokenRecord
  class RowMapper
    def initialize(params)
      extend Composable

      @key    = params.fetch(:key, nil)
      @mapper = params.fetch(:mapper)

      @row    = Row.new(:values       => params.fetch(:fields, {}),
                        :column_names => @mapper.column_names)

      features << @row
    end

    def save
      if @key
        @mapper.update(@key, @row.to_hash)
      else
        @mapper.create(@row.to_hash)
      end
    end

    def destroy
      @mapper.destroy(@key)
    end

    # override this!
    def valid?
      true
    end
  end
end
