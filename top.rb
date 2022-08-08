require "sinatra"
require "sinatra/reloader"
require "csv"

get "/" do

  arr = []
  CSV.foreach("post.csv") do |line|
    arr << line
  end

  @title = []
  arr.each do |frame|
    @title << frame[0]
  end

  erb :index
end

get "/new" do
  erb :new
end

get "/show" do
  erb :show
end

get "/edit" do
  erb :edit
end

post "/" do
  @title = params[:title]
  @text = params[:text]
  CSV.open("post.csv", "a") do |csv|
    csv << [@title, @text]
  end

  redirect to('/')
end