require "mozart"

module BrokenRecord
  module Mapping
    include Mozart::Composable

    def initialize(params)
      features << Record.new(params)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      include Mozart::Composable

      def map_to_table(table_name)
        features << Relation.new(:name         => table_name,
                                 :db           => BrokenRecord.database,
                                 :record_class => self)
      end
    end
  end
end
