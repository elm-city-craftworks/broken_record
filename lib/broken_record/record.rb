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
        _(:relation).update(key, to_hash)
      else
        _(:relation).create(to_hash)
      end
    end

    def destroy
      _(:relation).destroy(key)
    end
  end
end
