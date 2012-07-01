require_relative "helper"

class Stack
  def initialize
    @data = []
  end

  def push(obj)
    data.push(obj)
  end

  def pop
    data.pop
  end

  def size
    data.size
  end

  def each
    data.reverse_each { |e| yield(e) }
  end

  private

  attr_reader :data
end

class EnumerableStack
  include BrokenRecord::Composable

  def initialize
    stack = Stack.new
    enum  = Enumerator.new { |y| stack.each { |e| y.yield(e) } }      

    features << stack << enum
  end
end

stack = EnumerableStack.new

stack.push(10)
stack.push(20)
stack.push(30)

p stack.map { |x| "Has element: #{x}" } #=~
# ["Has element: 30", "Has element: 20", "Has element: 10"]
