require_relative "helper"

class Article
  include BrokenRecord::Mapping

  map_to_table :articles

  def published?
    status == "published"
  end
end

Article.create(:title  => "A great article",
               :body   => "The rain in Spain...",
               :status => "draft")

Article.create(:title  => "A mediocre article",
               :body   => "Falls mainly in the plains",
               :status => "published")

Article.create(:title  => "A bad article",
               :body   => "Is really bad!",
               :status => "published")

Article.all.each do |article|
  if article.published?
    puts "PUBLISHED: #{article.title}"
  else
    puts "UPCOMING: #{article.title}"
  end
end
