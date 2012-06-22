require_relative "helper"

class MinimalModel
  def initialize(params)
    @values   = params[:values]
    @key      = params[:key]
    @relation = params[:relation]
  end

  def id
    @key
  end

  attr_reader :values, :key, :relation
end

class Article < MinimalModel
end

class Comments < MinimalModel
  def initialize(params)
    @values   = params[:values]
    @key      = params[:key]
    @relation = params[:relation]
  end

  attr_reader :values, :key, :relation
end

relation = BrokenRecord::Relation.new(:name         => "articles",
                                      :record_class => Article)

relation.create(:title => "Article 1", :body => "AWESOME")
relation.create(:title => "Article 2", :body => "TERRIBLE")

p relation.all.map { |e| [e.key, e.values[:title]] }

relation.has_many(:comments, :class => "Comments", :key => "article_id")

p relation.all.map { |e| e.comments.count }
