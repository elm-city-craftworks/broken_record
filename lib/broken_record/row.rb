class BrokenRecord
  class Row
    def initialize(attributes)
      singleton_class.instance_eval do
        attr_accessor(*attributes.keys)   
      end

      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end
  end
end
