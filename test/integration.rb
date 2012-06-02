require "minitest/autorun"
require "sqlite3"

require_relative "../lib/broken_record"

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

    @article_model = Class.new do
      include BrokenRecord::Mapping
      
      map_to_table :articles
    end

    @articles.each do |title, body|
      @article_model.create(:title => title, :body => body)
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

  it "must allow destroying records" do
    @article_model.find(1).wont_be_nil
    @article_model.destroy(1)
    @article_model.find(1).must_be_nil
  end

  after do
    BrokenRecord.database.close
  end
end
