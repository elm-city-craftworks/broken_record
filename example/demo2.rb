require_relative "helper"

class Article
  include BrokenRecord::Mapping
  
  map_to_table :articles

  has_many :comments, :key   => :article_id,
                      :class => "Comment"
end

class Comment
  include BrokenRecord::Mapping

  map_to_table :comments

  belongs_to :article, :key   => :article_id,
                       :class => "Article"
end


article1 = Article.create(:title => "A great article",
                          :body  => "Short but sweet!")

article2 = Article.create(:title => "A not so great article",
                          :body  => "Just as short")

Comment.create(:body => "Supportive comment!", :article_id => article1.id)
Comment.create(:body => "Friendly comment!",   :article_id => article1.id)

Comment.create(:body => "Angry comment!",     :article_id => article2.id)
Comment.create(:body => "Frustrated comment!", :article_id => article2.id)
Comment.create(:body => "Irritated comment!", :article_id => article2.id)


Article.all.each do |article|
  puts %{
    TITLE: #{article.title}
    BODY: #{article.body}
    COMMENTS:\n#{article.comments.map { |e| "    - #{e.body}" }.join("\n")}
  }
end

=begin OUTPUT
    TITLE: A great article
    BODY: Short but sweet!
    COMMENTS:
    - Supportive comment!
    - Friendly comment!


    TITLE: A not so great article
    BODY: Just as short
    COMMENTS:
    - Angry comment!
    - Frusrated comment!
    - Irritated comment!  
=end
