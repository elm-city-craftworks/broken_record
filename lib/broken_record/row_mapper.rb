require_relative "composable"
require_relative "row"

module BrokenRecord
  class RowMapper
    include Composable

    def initialize(params)
      self.key    = params.fetch(:key, nil)
      self.mapper = params.fetch(:mapper)

      features << Row.new(:values       => params.fetch(:fields, {}),
                          :column_names => @mapper.column_names)
    end

    def save
      if key
        mapper.update(key, to_hash)
      else
        mapper.create(to_hash)
      end
    end

    def destroy
      mapper.destroy(key)
    end

    # override this!
    def valid?
      true
    end

    private

    attr_accessor :mapper, :key, :row

  end
end
