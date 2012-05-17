require "minitest/autorun"
require_relative "../lib/broken_record/row"

describe BrokenRecord::Row do
  it "must create readers for all attributes" do
    row = BrokenRecord::Row.new(:a => 1, :b => 2)

    row.a.must_equal(1)
    row.b.must_equal(2)
  end
end
