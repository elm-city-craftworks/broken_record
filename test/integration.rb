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

    @articles = [["Article 1", "The rain in Spain"],
                ["Article 2", "Falls mainly in the plains"]]

    @articles.each do |pair|
      BrokenRecord.database.execute("insert into articles values (null, ?, ?)", pair) 
    end

    @article_model = Class.new do
      include BrokenRecord::Mapping

      define_table :articles do 
        columns do
          integer :id
          text    :title
          text    :body
        end
      end
    end
  end

  it "must provide readers for fields" do
    @article_model.all.map { |r| [r.title, r.body] }.must_equal(@articles)
  end

  it "must allow saving changes to fields" do
    article = @article_model.find(1)

    article.title = "Changed Title"

    article.title.must_equal("Changed Title")

    @article_model.find(1).title.wont_equal(article.title)

    article.save

    @article_model.find(1).title.must_equal(article.title)
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

    def build_row(table, row_data)
      @record_class.new(table, Hash[@fields.zip(row_data)])
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

    def update(id, params)
      # FIXME: This is probably not secure
      sql = params.map { |k,v| "#{k} = #{v.inspect}" }.join(", ")

      BrokenRecord.database.execute %{
        update #{@table_name}
        set #{sql}
        where id = #{id}
      }
    end

    def all
      BrokenRecord.database.query( "select * from #{@table_name}" ) do |results|
        return results.map { |r| @row_builder.build_row(self, r) }
      end
    end

    # FIXME: Blech!
    def find(id)
      BrokenRecord.database.query( "select * from #{@table_name} where id = ?", [id] ) do |results|
        return results.map { |r| @row_builder.build_row(self, r) }.first
      end
    end
  end

  class Row
    def initialize(table, params)
      @table = table
      @data  = Struct.new(*params.keys.map(&:to_sym)).new(*params.values)
    end

    def save
      params = Hash[@data.each_pair.to_a]
      id     = params.delete(:id)

      @table.update(id, params)
    end

    def method_missing(m, *a, &b)
      @data.public_send(m, *a, &b)
    end
  end
  
  module Mapping
    def initialize(table, params)
      @__row__   = Row.new(table, params)
    end

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

      def method_missing(m, *a, &b)
        @__table__.public_send(m, *a, &b)
      end
    end
  end
end
