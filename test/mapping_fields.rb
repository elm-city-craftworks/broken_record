require "minitest/autorun"
require "delegate"

require "sqlite3"

describe "Mapping fields in results" do
  before do
    BrokenRecord.database = SQLite3::Database.new(":memory:")
   
    BrokenRecord.database.execute %{
      create table articles ( 
        title text,
        body  text
      );
    }
  end

  it "must provide readers for fields" do
    articles = [["Article 1", "The rain in Spain"],
                ["Article 2", "Falls mainly in the plains"]]

    articles.each do |pair|
      BrokenRecord.database.execute("insert into articles values (?, ?)", pair) 
    end

    article_model = Class.new do
      include BrokenRecord::Mapping

      define_map :articles do 
        fields do
          text :title
          text :body
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
    def initialize
      @fields = []
    end

    def text(name)
      @fields << name
    end

    def to_struct
      Struct.new(*@fields)
    end
  end

  class Mapper
    def initialize(table_name, &block)
      @table_name  = table_name
      @row_builder = RowBuilder.new

      SimpleDelegator.new(self).instance_eval(&block)
    end

    def fields(&block)
      SimpleDelegator.new(@row_builder).instance_eval(&block)
    end

    def all
      BrokenRecord.database.query( "select * from #{@table_name}" ) do |results|
        struct = @row_builder.to_struct
        return results.map { |r| struct.new(*r) }
      end
    end
  end
  
  module Mapping
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def define_map(table_name, &block)
        @__mapper__ = Mapper.new(table_name, &block)
      end

      def all
        @__mapper__.all
      end
    end
  end
end


