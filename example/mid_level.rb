require_relative "helper"

class Article
  def initialize(params)
    @params = params
  end

  def to_s
    "TITLE: #{@params[:values][:title]}\n"+
    "BODY:  #{@params[:values][:body]}"
  end
end

# a factory for record objects that interacts with Table
articles = BrokenRecord::Relation.new(:record_class => Article,
                                      :name         => "articles")

articles.create(:title => "A great article",
                :body  => "Short but sweet")

articles.create(:title => "A not so great article",
                :body  => "Just as short")


puts articles.all.join("\n\n") #=~
# TITLE: A great article
# BODY:  Short but sweet
#
# TITLE: A not so great article
# BODY:  Just as short
