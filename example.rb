require "sqlite3"
require_relative "lib/broken_record"

BrokenRecord.database = SQLite3::Database.new(":memory:")

BrokenRecord.database.execute %{
  create table articles ( 
    id     integer primary key,
    title  text,
    body   text,
    status text
  );
}

class Article
  include BrokenRecord::Mapping

  map_to_table :articles

  def published?
    status == "published"
  end
end

article = Article.create(:title  => "First Article",
                         :body   => "The Rain in Spain",
                         :status => "draft")

p article.published?

article.status = "published"

p article.published?

p Article.find(1).published?
article.save
p Article.find(1).published?

article.destroy

p Article.find(1)
