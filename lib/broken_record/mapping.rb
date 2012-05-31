module BrokenRecord
  module Mapping
    def initialize(table, params)
      @__row__ = Row.new(table, params)
    end

    def method_missing(m, *a, &b)
      @__row__.public_send(m, *a, &b)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def define_table(table_name, &block)
        @__table__ = RecordTable.new(self, table_name, &block)
      end

      def method_missing(m, *a, &b)
        @__table__.public_send(m, *a, &b)
      end
    end
  end
end
