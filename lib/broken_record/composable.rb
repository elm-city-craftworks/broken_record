module BrokenRecord
  module Composable
    def features
      @__features__ ||= Composite.new
    end

    def respond_to_missing?(m, _)
      features.receives?(m)
    end

    def method_missing(m, *a, &b)
      features.dispatch(m, *a, &b)
    end
  end

  class Composite 
    def initialize
      self.receivers = []
    end

    def <<(obj)
      receivers.push(obj)
    end

    def >>(obj)
      receivers.shift(obj)
    end

    def receives?(m)
      !!receiver(m)
    end

    def dispatch(m, *a, &b)
      obj = receiver(m)

      raise NoMethodError, "No compenent implements #{m}" unless obj

      obj.send(m, *a, &b)
    end

    private

    def receiver(m)
      receivers.find { |c| c.respond_to?(m) }
    end

    attr_accessor :receivers
  end
end
