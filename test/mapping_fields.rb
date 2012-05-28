require "minitest/autorun"
require "delegate"

require "sqlite3"

describe "Mapping fields in results" do
  before do
    BrokenRecord.database = SQLite3::Database.new(":memory:")
   
    BrokenRecord.database.execute %{
      create table articles ( 
        id    integer primary key,
        title text,
        body  text
      );
    }
  end

  it "must provide readers for fields" do
    articles = [["Article 1", "The rain in Spain"],
                ["Article 2", "Falls mainly in the plains"]]

    articles.each do |pair|
      BrokenRecord.database.execute("insert into articles values (null, ?, ?)", pair) 
    end

    article_model = Class.new do
      include BrokenRecord::Mapping

      define_table :articles do 
        columns do
          integer :id
          text    :title
          text    :body
        end
      end
    end

    article_model.all.map { |r| [r.title, r.body] }.must_equal(articles)
  end

  after do
    BrokenRecord.database.close
  end
end

## IMPLEMENTATION

module BrokenRecord
  class << self
    attr_accessor :database
  end

  class RowBuilder
    def initialize(record_class)
      @record_class = record_class
      @fields       = []
    end

    def text(name)
      @fields << name
    end

    def integer(name)
      @fields << name
    end

    def build_row(row_data)
      @record_class.new(Hash[@fields.zip(row_data)])
    end
  end

  class Table
    def initialize(record_class, table_name, &block)
      @table_name  = table_name
      @row_builder = RowBuilder.new(record_class)

      SimpleDelegator.new(self).instance_eval(&block)
    end

    def columns(&block)
      SimpleDelegator.new(@row_builder).instance_eval(&block)
    end

    def all
      BrokenRecord.database.query( "select * from #{@table_name}" ) do |results|
        return results.map { |r| @row_builder.build_row(r) }
      end
    end
  end

  class Row
    def initialize(params)
      @data = Struct.new(*params.keys.map(&:to_sym)).new(*params.values)
    end

    def method_missing(m, *a, &b)
      @data.public_send(m, *a, &b)
    end
  end
  
  module Mapping
    def initialize(params)
      @__row__ = Row.new(params)
    end

    # FIXME: I wanted to use public_send but may have run into a Ruby bug
    def method_missing(m, *a, &b)
      @__row__.public_send(m, *a, &b)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def define_table(table_name, &block)
        @__table__ = Table.new(self, table_name, &block)
      end

      def all
        @__table__.all
      end
    end
  end
end


