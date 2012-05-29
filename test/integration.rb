require "minitest/autorun"
require "delegate"
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
