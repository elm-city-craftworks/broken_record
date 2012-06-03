require "sqlite3"
require_relative "../lib/broken_record"

BrokenRecord.database = SQLite3::Database.new(":memory:")

# NOTE: This only works on sqlite3 >= 3.6.19: Previous versions
# will parse the foreign keys but not enforce them.
BrokenRecord.database.execute("PRAGMA foreign_keys = ON;")

BrokenRecord.database.execute_batch %{
  create table articles ( 
    id     INTEGER PRIMARY KEY,
    title  TEXT,
    body   TEXT,
    status TEXT
  );

  create table comments (
    id          INTEGER PRIMARY KEY,
    body        TEXT,
    article_id  INTEGER,
    FOREIGN KEY(article_id) REFERENCES articles(id)
  );
}
