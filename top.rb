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

get '/memos/new' do
  erb :new
end

# メモ詳細画面
get '/memos/:detail_id' do
  detail_id = params['detail_id']

  array = CSV.open('post.csv').detect { |line| detail_id == line[0] }
  @id = array[0]
  @title = array[1]
  @text = array[2]
  erb :detail
end

# メモ編集画面
get '/memos/:detail_id/edits' do
  detail_id = params['detail_id']

  array = CSV.open('post.csv').detect { |line| detail_id == line[0] }
  @id = array[0]
  @title = array[1]
  @text = array[2]
  erb :edit
end

### POSTメソッドの処理

# 新規作成ページ
post '/memos/new' do
  random = SecureRandom.alphanumeric
  title = params[:title]
  text = params[:text]

  CSV.open('post.csv', 'a') do |csv|
    csv << [random, title, text]
  end

  redirect to('/')
end

# メモ詳細ページ(patch)
patch '/memos/:detail_id' do
  detail_id = params['detail_id']
  title = params[:title]
  text = params[:text]

  @line_arr = CSV.read('post.csv')

  CSV.open('post.csv', 'w') do |csv|
    @line_arr.each do |frame|
      csv << if detail_id == frame[0]
              [frame[0], frame[1] = title, frame[2] = text]
            else
              frame
            end
    end
  end
  redirect to("memos/#{detail_id}")
end

# メモ詳細ページ(delete)
delete '/memos/:detail_id' do
  delete_id = params['detail_id']
  CSV.open('post.csv').reject { |line| delete_id == line[0] }
  redirect to('/')
end
