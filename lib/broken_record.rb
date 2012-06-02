require_relative "broken_record/row"
require_relative "broken_record/table"
require_relative "broken_record/mapping"
require_relative "broken_record/table_mapper"
require_relative "broken_record/composable"

module BrokenRecord
  class << self
    attr_accessor :database
  end
end
