require_relative "composable"
require_relative "table_mapper/crud"
require_relative "table_mapper/associations"

module BrokenRecord
  class TableMapper
    include Composable

    def initialize(params)
      self.table = Table.new(:name => params.fetch(:name),
                             :db   => BrokenRecord.database)

      self.record_class = params.fetch(:record_class)

      features << CRUD.new(self) << Associations.new(self)
    end

    attr_reader :table, :record_class

    def column_names
      table.columns.keys
    end

    def primary_key
      table.primary_key
    end

    private

    attr_writer :table, :record_class
  end
end
