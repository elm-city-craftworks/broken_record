require "minitest/autorun"
require "sqlite3"

require_relative "../lib/broken_record"

describe "Mapping fields in results" do
  before do
    BrokenRecord.database = SQLite3::Database.new(":memory:")

    # NOTE: This only works on sqlite3 >= 3.6.19: Previous versions
    # will parse the foreign keys but not enforce them.
    BrokenRecord.database.execute("PRAGMA foreign_keys = ON;")
       
    BrokenRecord.database.execute_batch %{
      create table articles ( 
        id    integer primary key,
        title text,
        body  text
      );

      create table comments (
        id          integer primary key,
        body        text,
        article_id  integer,
        foreign key(article_id) references articles(id)
      );
    }

    # Wow... could we do better than this? Singleton state is the devil!
    Object.send(:remove_const, :Article) if defined?(Article)
    Object.send(:const_set, :Article, Class.new do
      include BrokenRecord::Mapping
      
      map_to_table :articles
      has_many :comments, :key => :article_id, :class => "Comment"
    end)

    Object.send(:remove_const, :Comment) if defined?(Comment)
    Object.send(:const_set, :Comment, Class.new do
      include BrokenRecord::Mapping

      map_to_table :comments
      belongs_to :article, :key => :article_id, :class => "Article"
    end)

    @articles = [["Article 1", "The rain in Spain"],
                ["Article 2", "Falls mainly in the plains"]]

    @articles.each do |title, body|
      Article.create(:title => title, :body => body)
    end

    @comments = [["Awesome!", 1], ["Terrible!", 2], ["Meh", 1]]

    @comments.each do |body, article_id|
      Comment.create(:body => body, :article_id => article_id)
    end
  end

  it "must provide readers for fields" do
    Article.all.map { |r| [r.title, r.body] }.must_equal(@articles)
  end

  it "must allow saving changes to fields" do
    article = Article.find(1)

    article.title = "Changed Title"
    article.title.must_equal("Changed Title")

    Article.find(1).title.wont_equal(article.title)

    article.save

    Article.find(1).title.must_equal(article.title)
  end

  it "must allow destroying records" do
    Article.find(1).wont_be_nil
    Article.find(1).comments.each { |c| c.destroy }

    Article.destroy(1)
    Article.find(1).must_be_nil
  end

  it "must allow filtering" do
    a1 = Article.where(:title => "Article 1").first
    a1.body.must_equal "The rain in Spain"

    a2 = Article.where(:title => "Article 2").first
    a2.body.must_equal("Falls mainly in the plains")
  end

  it "must support associations" do
    Article.find(1).comments.count.must_equal(2) 
    Article.find(2).comments.count.must_equal(1) 

    Comment.find(1).article.id.must_equal(Article.find(1).id)
    Comment.find(2).article.id.must_equal(Article.find(2).id)
    Comment.find(3).article.id.must_equal(Article.find(1).id)
  end

  after do
    BrokenRecord.database.close
  end
end
