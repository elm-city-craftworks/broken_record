require_relative "composable"
require_relative "row"

module BrokenRecord
  class RowMapper
    include Composable

    def initialize(params)
      self.key      = params.fetch(:key, nil)
      self.relation = params.fetch(:relation)

      features << Row.new(:values       => params.fetch(:fields, {}),
                          :column_names => relation.column_names)
    end

    def save
      if key
        relation.update(key, to_hash)
      else
        relation.create(to_hash)
      end
    end

    def destroy
      relation.destroy(key)
    end

    # override this!
    def valid?
      true
    end

    private

    attr_accessor :relation, :key
  end
end
