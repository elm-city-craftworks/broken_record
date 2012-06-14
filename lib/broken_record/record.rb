require_relative "composable"
require_relative "field_set"

module BrokenRecord
  class Record
    include Composable

    def initialize(params)
      self.key      = params.fetch(:key, nil)
      self.relation = params.fetch(:relation)

      features << FieldSet.new(:values     => params.fetch(:values, {}),
                               :attributes => relation.attributes)
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
