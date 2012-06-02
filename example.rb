require "sqlite3"
require_relative "lib/broken_record"

BrokenRecord.database = SQLite3::Database.new(":memory:")

BrokenRecord.database.execute_batch %{
  create table articles ( 
    id     INTEGER PRIMARY KEY,
    title  TEXT,
    body   TEXT,
    status TEXT
  );

  create table comments (
    id          integer primary key,
    body        text,
    article_id  integer,
    FOREIGN KEY(article_id) REFERENCES articles(id)
  );
}


class Article
  include BrokenRecord::Mapping

  map_to_table :articles

#  has_many :comments, :key   => :article_id, 
#                      :class => Comment


  def published?
    status == "published"
  end
end


class Comment
  include BrokenRecord::Mapping

  map_to_table :comments

 # belongs_to :article, :key   => :article_id,
 #                      :class => Article
end



article = Article.create(:title  => "First Article",
                         :body   => "The Rain in Spain",
                         :status => "draft")

p Comment.create(:body => "YAY", :article_id => 7).id

exit

p article.published?

article.status = "published"

p article.published?

p Article.find(1).published?
article.save
p Article.find(1).published?

article.destroy

p Article.find(1)

p Article.find(1).comments
