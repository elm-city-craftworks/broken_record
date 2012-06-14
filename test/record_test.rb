require "minitest/autorun"
require "ostruct"

require_relative "../lib/broken_record/record"

describe BrokenRecord::Record do
  let(:relation) do
    mock = MiniTest::Mock.new
    mock.expect(:attributes, [:id, :title, :body])
    mock.expect(:primary_key, :id)

    mock
  end

  it "must be able to convert fields into accessors" do
    row = BrokenRecord::Record.new(:relation => relation)

    row.title = "Article 1"
    row.body  = "An amazing article"

    row.title.must_equal("Article 1")
    row.body.must_equal("An amazing article")
  end

  it "must be able to create a new database record" do
    row = BrokenRecord::Record.new(:relation => relation)

    row.title = "Article 1"
    row.body  = "An amazing article"

    insert_params = { :id               => nil,
                      :title            => "Article 1",
                      :body             => "An amazing article" }
    
    relation.expect(:create, Object, [insert_params])
    row.save
  end

  it "must be able to update an existing database record" do
    original_fields = { :id               => 1,
                        :title            => "Article 1",
                        :body             => "An amazing article" }

    row = BrokenRecord::Record.new(:relation => relation, 
                                      :key    => 1,
                                      :fields => original_fields)

    row.body = "An updated article"

    update_params = { :id               => 1,
                      :title            => "Article 1",
                      :body             => "An updated article" }

    relation.expect(:update, Object, [1, update_params])

    row.save
  end
end
