require_relative "helper"

class Article
  def initialize(params)
    @fieldset = BrokenRecord::FieldSet.new(
      :values     => params[:values],
      :attributes => params[:relation].attributes
    )
  end

  def to_s
    "TITLE: #{title}\n"+
    "BODY:  #{body}"
  end

  def respond_to_missing?(m, *a)
    fieldset.respond_to?(m)
  end

  def method_missing(m, *a, &b)
    fieldset.send(m, *a, &b)
  end

  private

  attr_reader :fieldset
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
