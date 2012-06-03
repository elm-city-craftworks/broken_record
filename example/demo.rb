require_relative "helper"

class Article
  include BrokenRecord::Mapping

  map_to_table :articles

  has_many :comments, :key   => :article_id, 
                      :class => "Comment"


  def published?
    status == "published"
  end
end


class Comment
  include BrokenRecord::Mapping

  map_to_table :comments

  belongs_to :article, :key   => :article_id,
                       :class => "Article"
end



article = Article.create(:title  => "First Article",
                         :body   => "The Rain in Spain",
                         :status => "draft")

c = Comment.create(:body => "YAY", :article_id => 1)
c2 = Comment.create(:body => "YAYZ", :article_id => 1)

p article.comments.map(&:body)
