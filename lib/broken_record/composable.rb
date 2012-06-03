module BrokenRecord
  module Composable
    def features
      @__features__ ||= Composite.new
    end

    def method_missing(m, *a, &b)
      features.public_send(m, *a, &b)
    end
  end

  class Composite 
    def initialize(head=nil, tail=nil)
      @head = head
      @tail = tail
    end

    def <<(obj)
      if @head.nil?
        @head = obj
      elsif @tail.nil?
        @tail = obj
      else
        @tail = self.class.new(@tail, obj)
      end

      self
    end

    def >>(obj)
      if @head.nil?
        @head = obj
      elsif @tail.nil?
        @tail = @head
        @head = obj
      else
        @tail = self.class.new(@head, @tail)
        @head = obj
      end

      self
    end

    def method_missing(m, *a, &b)
      return super unless @head

      @head.public_send(m, *a, &b)
    rescue NoMethodError
      return super unless @tail

      @tail.public_send(m, *a, &b)
    end
  end
end
