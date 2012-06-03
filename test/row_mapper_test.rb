require "minitest/autorun"
require "ostruct"

require_relative "../lib/broken_record/row_mapper"

describe BrokenRecord::RowMapper do
  let(:table) do
    columns = { :id    => { :type => "integer" },
                :title => { :type => "text"    },
                :body  => { :type => "text"    } }

    mock = MiniTest::Mock.new
    mock.expect(:columns, columns)
    mock.expect(:primary_key, :id)

    mock
  end

  it "must be able to convert fields into accessors" do
    row = BrokenRecord::RowMapper.new(:table => table)

    row.title = "Article 1"
    row.body  = "An amazing article"

    row.title.must_equal("Article 1")
    row.body.must_equal("An amazing article")
  end

  it "must be able to create a new database record" do
    row = BrokenRecord::RowMapper.new(:table => table)

    row.title = "Article 1"
    row.body  = "An amazing article"

    insert_params = { table.primary_key => nil, 
                      :title            => "Article 1",
                      :body             => "An amazing article" }
    
    table.expect(:insert, 1, [insert_params])
    row.save
  end

  it "must be able to update an existing database record" do
    original_fields = { table.primary_key => 1,
                        :title            => "Article 1",
                        :body             => "An amazing article" }

    row = BrokenRecord::RowMapper.new(:table  => table, 
                                :key    => 1,
                                :fields => original_fields)

    row.body = "An updated article"

    update_params = { table.primary_key => 1,
                      :title            => "Article 1",
                      :body             => "An updated article" }

    table.expect(:update, nil, [{ :where  => { table.primary_key => 1 },
                                  :fields => update_params}])

    row.save
  end
end
