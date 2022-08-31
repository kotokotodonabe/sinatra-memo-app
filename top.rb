require "sinatra"
require "sinatra/reloader"
require "csv"
require "securerandom"
require "pry"

enable :method_override

# トップページ
get "/" do

  @multi_arr = []
  CSV.foreach("post.csv") do |line|
    @multi_arr << line
  end

  erb :index
end

get "/new" do
  erb :new
end

# メモ詳細画面
get "/details/:detail_id" do
  detail_id = params['detail_id']

  CSV.foreach("post.csv") do |line|
    if detail_id == line[0]
      @uri = line[0]
      @title = line[1]
      @text = line[2]
    end
  end
  erb :detail
end

# メモ編集画面
get "/details/:detail_id/edits" do
  detail_id = params['detail_id']

  CSV.foreach("post.csv") do |line|
    if detail_id == line[0]
      @uri = line[0]
      @title = line[1]
      @text = line[2]
    end
  end
  erb :edit
end


### POSTメソッドの処理

# トップページ
post "/" do
  @title = params[:title]
  @text = params[:text]
  @random = SecureRandom.alphanumeric()

  CSV.open("post.csv", "a") do |csv|
    csv << [@random, @title, @text]
  end

  redirect to('/')
end

# メモ詳細ページ(patch)
patch "/details/:detail_id" do
  detail_id = params['detail_id']
  @title = params[:title]
  @text = params[:text]
  @line_arr = []
  
  File.open("post.csv", "r+") do |csv|
    csv.each_line do |line|
      @line_arr << line.chomp.split(',')
    end
  end

  @line_arr.map do |frame|
    if detail_id == frame[0]
      frame[1] = @title
      frame[2] = @text
    end
  end

  CSV.open("post.csv", "w") do |csv|
    @line_arr.each do |frame| 
      csv << frame
    end
  end
  
  redirect to("details/#{detail_id}")
end

# メモ詳細ページ(delete)
delete "/:detail_id/delete" do
  delete_id = params['detail_id']
  @csv_arr = []
  
  File.open("post.csv", "r+") do |csv|
    csv.each_line do |line|
      line_arr = line.chomp.split(',')
      if delete_id == line_arr[0]
        line_arr.delete(0..2)
      else
        @csv_arr << line_arr
      end
    end
  end

  CSV.open("post.csv", "w") do |csv|
    @csv_arr.each do |frame|
      csv << frame
    end
  end
  
  redirect to("/")
end