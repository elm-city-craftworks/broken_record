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



Article.create(:title  => "A great articles",
               :body   => "The Rain in Spain",
               :status => "draft")


Comment.create(:body => "A first comment",  :article_id => 1)
Comment.create(:body => "A second comment", :article_id => 1)


article = Article.find(1)

puts "#{article.title} -- #{article.comments.count} comments"
puts article.comments.map { |e| "  * #{e.body}" }.join("\n")

print "This article is: "
puts article.published? ? "Published!" : "Not Yet Published!"

puts "\n\nAFTER SOME CHANGES:\n\n"

# after some changes...

article.comments.last.destroy

Comment.create(:body => "A third comment", :article_id => 1)
Comment.create(:body => "A fourth comment", :article_id => 1)

article.status = "published"
article.save

puts "#{article.title} -- #{article.comments.count} comments"
puts article.comments.map { |e| "  * #{e.body}" }.join("\n")

print "This article is: "
puts article.published? ? "Published!" : "Not Yet Published!"
