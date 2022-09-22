# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'securerandom'
require 'pry'

enable :method_override

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
  @multi_arr = []
  CSV.foreach('post.csv') do |line|
    @multi_arr << line
  end

  erb :index
end

get '/new' do
  erb :new
end

# メモ詳細画面
get '/memos/:detail_id' do
  detail_id = params['detail_id']

  CSV.foreach('post.csv') do |line|
    if detail_id == line[0]
      @uri,@title,@text = line[0],line[1],line[2]
    end
  end
  erb :detail
end

# メモ編集画面
get '/memos/:detail_id/edits' do
  detail_id = params['detail_id']

  CSV.foreach('post.csv') do |line|
    if detail_id == line[0]
      @uri,@title,@text = line[0],line[1],line[2]
    end
  end
  erb :edit
end

### POSTメソッドの処理

# トップページ
post '/' do
  @random = SecureRandom.alphanumeric
  @title = params[:title]
  @text = params[:text]
  binding.pry

  CSV.open('post.csv', 'a') do |csv|
    csv << [@random, @title, @text]
  end

  redirect to('/')
end

# メモ詳細ページ(patch)
patch '/memos/:detail_id' do
  detail_id = params['detail_id']
  @title,@text = params[:title], params[:text]

  @line_arr = []
  CSV.open('post.csv', 'r') do |csv|
    csv.each do |line|
      @line_arr << line
    end
  end

  @line_arr.each do |frame|
    if detail_id == frame[0]
      frame[1], frame[2] = @title, @text
    end
  end

  CSV.open('post.csv', 'w') do |csv|
    @line_arr.each do |frame|
      csv << frame
    end
  end
  redirect to("memos/#{detail_id}")
end

# メモ詳細ページ(delete)
delete '/:detail_id' do
  delete_id = params['detail_id']
  @csv_arr = []
  CSV.open('post.csv', 'r+') do |csv|
    csv.reject do |line|
      if delete_id != line[0]
        @csv_arr << line
      end
    end
  end
  CSV.open('post.csv', 'w') do |csv|
    @csv_arr.each do |frame|
      csv << frame
    end
  end
  redirect to('/')
end
