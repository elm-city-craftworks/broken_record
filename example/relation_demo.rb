require_relative "helper"

class Article
  def initialize(params)
    @params = params
  end

  attr_reader :params
end

relation = BrokenRecord::Relation.new(:name         => "articles",
                                      :record_class => Article)

relation.create(:title => "Article 1", :body => "AWESOME")
relation.create(:title => "Article 2", :body => "TERRIBLE")

relation.all.map { |e| e.params[:body] }
