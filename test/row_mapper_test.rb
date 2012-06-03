require "minitest/autorun"
require "ostruct"

require_relative "../lib/broken_record/row_mapper"

describe BrokenRecord::RowMapper do
  let(:mapper) do
    mock = MiniTest::Mock.new
    mock.expect(:column_names, [:id, :title, :body])
    mock.expect(:primary_key, :id)

    mock
  end

  it "must be able to convert fields into accessors" do
    row = BrokenRecord::RowMapper.new(:mapper => mapper)

    row.title = "Article 1"
    row.body  = "An amazing article"

    row.title.must_equal("Article 1")
    row.body.must_equal("An amazing article")
  end

  it "must be able to create a new database record" do
    row = BrokenRecord::RowMapper.new(:mapper => mapper)

    row.title = "Article 1"
    row.body  = "An amazing article"

    insert_params = { :id               => nil,
                      :title            => "Article 1",
                      :body             => "An amazing article" }
    
    mapper.expect(:create, Object, [insert_params])
    row.save
  end

  it "must be able to update an existing database record" do
    original_fields = { :id               => 1,
                        :title            => "Article 1",
                        :body             => "An amazing article" }

    row = BrokenRecord::RowMapper.new(:mapper => mapper, 
                                      :key    => 1,
                                      :fields => original_fields)

    row.body = "An updated article"

    update_params = { :id               => 1,
                      :title            => "Article 1",
                      :body             => "An updated article" }

    mapper.expect(:update, Object, [1, update_params])

    row.save
  end
end
