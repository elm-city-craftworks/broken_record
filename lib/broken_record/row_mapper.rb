require_relative "composable"

module BrokenRecord
  class RowMapper
    def initialize(params)
      extend Composable

      @key    = params.fetch(:key, nil)
      @mapper = params.fetch(:mapper)

      build_accessors(params.fetch(:fields, {}))
    end

    def save
      fields = Hash[members.zip(values)]

      if @key
        @mapper.update(@key, fields)
      else
        @mapper.create(fields)
      end
    end

    def destroy
      @mapper.destroy(@key)
    end

    # override this!
    def valid?
      true
    end

    private

    def build_accessors(fields)
      data  = Struct.new(*@mapper.column_names).new

      fields.each { |k,v| data[k] = v }

      features << data
    end
  end
end
