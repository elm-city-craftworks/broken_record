module BrokenRecord
  module Composable
    def features
      @__features__ ||= Composite.new
    end

    def respond_to?(m)
      features.respond_to?(m) || super
    end

    def method_missing(m, *a, &b)
      features.dispatch(m, *a, &b)
    end
  end

  class Composite 
    def initialize
      @components = []
    end

    def <<(obj)
      components.push(obj)
    end

    def >>(obj)
      components.shift(obj)
    end

    def respond_to?(m)
      components.any? { |c| c.respond_to?(m) } || super
    end

    def dispatch(m, *a, &b)
      components.each do |c|
        return c.public_send(m, *a, &b) if c.respond_to?(m)
      end

      raise NoMethodError, "No compenent implements #{m}"
    end

    private

    attr_reader :components
  end
end
