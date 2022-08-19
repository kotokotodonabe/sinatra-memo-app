require "sinatra"
require "sinatra/reloader"
require "csv"
require "securerandom"

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

get "/detail/:detail_id" do
  detail = params['detail_id']
  CSV.foreach("post.csv", "r") do |csv|
    if detail == csv[0]
      @title = csv[1]
      @text = csv[2]
    end
  end
  erb :detail
end

get "/edit" do
  erb :edit
end

post "/" do
  @title = params[:title]
  @text = params[:text]

  @random = SecureRandom.alphanumeric()

  CSV.open("post.csv", "a") do |csv|
    csv << [@random, @title, @text]
  end

  redirect to('/')
end