module BrokenRecord
  class Row
    def initialize(params)
      self.data = {}

      column_names = params.fetch(:column_names)
      values       = params.fetch(:values)

      column_names.each { |name| data[name] = values[name] }

      build_accessors(column_names)
    end

    def to_hash
      Marshal.load(Marshal.dump(data))
    end

    private

    attr_accessor :data

    def build_accessors(column_names)
      column_names.each do |name|
        define_singleton_method(name) { data[name] }
        define_singleton_method("#{name}=") { |v| data[name] = v }
      end
    end
  end
end
