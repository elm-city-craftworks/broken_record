require_relative "helper"

## create a couple table objects

articles = BrokenRecord::Table.new(:name => "articles",
                                   :db   => BrokenRecord.database)

comments = BrokenRecord::Table.new(:name => "comments",
                                   :db   => BrokenRecord.database)

## create an article with some positive comments

a1 = articles.insert(:title => "A great article", 
                     :body  => "Short but sweet")

comments.insert(:body => "Supportive comment!", :article_id => a1)
comments.insert(:body => "Friendly comment!",   :article_id => a1)

## create an article with some negative comments

a2 = articles.insert(:title => "A not so great article", 
                     :body  => "Just as short")

comments.insert(:body => "Angry comment!",      :article_id => a2)
comments.insert(:body => "Frustrated comment!", :article_id => a2)
comments.insert(:body => "Irritated comment!",  :article_id => a2)

## Display the articles and their comments

articles.all.each do |article|
  responses = comments.where(:article_id => article[:id])

  puts %{
    TITLE: #{article[:title]}
    BODY: #{article[:body]}
    COMMENTS:\n#{responses.map { |e| "    - #{e[:body]}" }.join("\n") }
  }
end
