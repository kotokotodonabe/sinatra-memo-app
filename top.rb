# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'securerandom'
require 'pry'

enable :method_override

class Connect
  def self.conn
    @conn = PG.connect(dbname: 'memo')
  end
end

class Memo
  def self.create(url, title, text)
    Connect.conn.exec('INSERT INTO memos(url, title, text) VALUES($1, $2, $3);', [url, title, text])
  end

  def self.update(url, title, text)
    Connect.conn.exec('UPDATE memos SET title = $1, text = $2 WHERE url = $3;', [title, text, url])
  end

  def self.delete(url)
    Connect.conn.exec('DELETE FROM memos WHERE url = $1;', [url])
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

not_found do
  erb :not_found
end

# トップページ
get '/' do
  @memos = []
  Connect.conn.exec('SELECT url, title From memos') do |result|
    @memos = result.to_a
  end

  erb :index
end

get '/memos/new' do
  erb :new
end

# メモ詳細画面
get '/memos/:memo_id' do
  Connect.conn.exec('SELECT * from memos') do |result|
    @memo = result.find { |row| row['url'] == params[:memo_id] }
  end

  erb :show
end

# メモ編集画面
get '/memos/:memo_id/edits' do
  Connect.conn.exec('SELECT * from memos') do |result|
    @memo = result.find { |row| row['url'] == params[:memo_id] }
  end

  erb :edit
end

### POSTメソッドの処理

# トップページ
post '/' do
  url = SecureRandom.alphanumeric
  Memo.create(url, params[:title], params[:text])

  redirect to('/')
end

# メモ詳細ページ(patch)
patch '/memos/:memo_id' do
  memo_id = params[:memo_id]
  Memo.update(memo_id, params[:title], params[:text])

  redirect to("memos/#{memo_id}")
end

# メモ詳細ページ(delete)
delete '/memos/:memo_id' do
  Memo.delete(params[:memo_id].to_s)

  redirect to('/')
end
