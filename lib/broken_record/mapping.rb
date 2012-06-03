require_relative "composable"

module BrokenRecord
  module Mapping
    def initialize(params)
      extend Composable

      features << Row.new(params)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def map_to_table(table_name)
        extend Composable

        features << TableMapper.new(:name         => table_name,
                                    :db           => BrokenRecord.database,
                                    :record_class => self)
      end
    end
  end
end
