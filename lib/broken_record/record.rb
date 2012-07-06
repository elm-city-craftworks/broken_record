require "mozart"

module BrokenRecord
  class Record
    include Mozart::Environment

    def initialize(params)
      _(:key,      params.fetch(:key, nil))
      _(:relation, params.fetch(:relation))

      values = params.fetch(:values, {})
      features << Mozart.value(*_(:relation).attributes).new(values)
    end

    def key
      _(:key)
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

    private

    def relation
      _(:relation)
    end

  end
end
