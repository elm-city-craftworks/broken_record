require "minitest/autorun"
require "sqlite3"

require_relative "../lib/broken_record/table"

describe BrokenRecord::Table do
  let(:database) { SQLite3::Database.new(":memory:") }
  let(:table)    { BrokenRecord::Table.new(:name => "articles",
                                           :db   => database) }
  before do
   database.execute %{
      create table articles ( 
        id    integer primary key,
        title text,
        body  text
      );
    }
  end

  it "must be able to retrieve column information" do
    columns = table.columns

    columns.count.must_equal(3)

    columns[:id][:type].must_equal("integer")
    columns[:title][:type].must_equal("text")
    columns[:body][:type].must_equal("text")
  end

  it "must be able to create and retrieve row data" do
    params = { :title => "Article 1", 
               :body  => "The rain in spain" }

    id = table.insert(params)

    record = table.where(:id => id).first

    record[:id].must_equal(1)
    record[:title].must_equal(params[:title])
    record[:body].must_equal(params[:body])
  end

  it "must be able to delete rows" do
    params = { :title => "Article 1", 
               :body  => "The rain in spain" }

    id = table.insert(params)
    table.delete(:id => id)

    table.where(:id => id).must_be_empty
  end

  it "must be able to update rows" do
    params = { :title => "Article 1", 
               :body  => "The rain in spain" }

    id = table.insert(params)
   
    table.update(:where   => { :id    => id },
                 :fields  => { :body  => "Falls mainly on the plains" }) 

    table.where(:id => id).first[:body].must_equal("Falls mainly on the plains")
  end

  after do
    database.close
  end
end
