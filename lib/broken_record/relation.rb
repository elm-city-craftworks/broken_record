require "mozart"
require_relative "relation/crud"
require_relative "relation/associations"

module BrokenRecord
  class Relation
    include Mozart::Composable

    def initialize(params)
      self.table = Table.new(:name => params.fetch(:name),
                             :db   => params.fetch(:db))

      self.record_class = params.fetch(:record_class)

      features << CRUD.new(self) << Associations.new(self)
    end

    attr_reader :table

    def attributes
      table.columns.keys
    end

    def new_record(values)
      record_class.new(:relation => self,
                       :values   => values,
                       :key      => values[table.primary_key])
    end

    def define_record_method(name, &block)
      record_class.send(:define_method, name, &block)
    end

    private

    attr_reader :record_class
    attr_writer :table, :record_class
  end
end
