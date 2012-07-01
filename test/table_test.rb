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
        title  text,
        body   text,
        status text
      );
    }
  end

  it "must be able to determine primary key" do
    table.primary_key.must_equal(:id)
  end

  it "must be able to retrieve column information" do
    columns = table.columns

    columns.count.must_equal(4)

    columns[:id][:type].must_equal("integer")
    columns[:title][:type].must_equal("text")
    columns[:body][:type].must_equal("text")
    columns[:status][:type].must_equal("text")
  end

  it "must be able to create and retrieve row data" do
    params = { :title  => "Article 1", 
               :body   => "The rain in spain",
               :status => "published"}

    id = table.insert(params)

    record = table.where(:id => id).first

    record[:id].must_equal(1)
    record[:title].must_equal(params[:title])
    record[:body].must_equal(params[:body])
    record[:status].must_equal(params[:status])
  end

  it "must be able to delete rows" do
    params = { :title  => "Article 1", 
               :body   => "The rain in spain",
               :status => "published" }

    id = table.insert(params)
    table.delete(:id => id)

    table.where(:id => id).must_be_empty
  end

  it "must be able to update rows" do
    params = { :title  => "Article 1", 
               :body   => "The rain in spain",
               :status => "publshed" }

    id = table.insert(params)
   
    table.update(:where   => { :id    => id },
                 :fields  => { :body  => "Falls mainly on the plains" }) 

    table.where(:id => id).first[:body].must_equal("Falls mainly on the plains")
  end

  it "must be able to filter rows with a simple query" do
    table.insert(:title  => "Article 1", 
                 :body   => "The rain in Spain",
                 :status => "draft")

    table.insert(:title  => "Article 2", 
                 :body   => "Falls mainly on the plains",
                 :status => "published")

    table.insert(:title  => "Article 3", 
                 :body   => "Oh that rain in Spain!",
                 :status => "published")


    table.where(:status => "draft").count.must_equal(1)
    table.where(:status => "published").count.must_equal(2)
  end

  after do
    database.close
  end
end
