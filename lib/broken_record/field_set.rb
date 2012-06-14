module BrokenRecord
  class FieldSet
    def initialize(params)
      self.data = {}

      attributes  = params.fetch(:attributes)
      values      = deep_copy(params.fetch(:values, {}))

      attributes.each { |name| data[name] = values[name] }

      build_accessors(attributes)
    end

    def to_hash
      deep_copy(data)
    end

    private

    attr_accessor :data

    def deep_copy(object)
      Marshal.load(Marshal.dump(object))
    end

    def build_accessors(attributes)
      attributes.each do |name|
        define_singleton_method(name) { data[name] }
        define_singleton_method("#{name}=") { |v| data[name] = v }
      end
    end
  end
end
