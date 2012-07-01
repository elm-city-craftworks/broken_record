require_relative "helper"

article_data = { :id    => 1,
                 :title => "A fancy article",
                 :body  => "This is so full of class, it's silly" }

article = BrokenRecord::FieldSet.new(:attributes => [:id, :title, :body],
                                     :values     => article_data)

p article.title #=> "A fancy title"

p article.to_hash == article_data #=> true

article.title = "A less fancy title"

p article.to_hash == article_data #=> false
p article.to_hash[:title]         #=> "A less fancy title"
