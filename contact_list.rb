require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"
require "securerandom"
require "yaml"
require "bcrypt"
require_relative "users"
include FileUtils::Verbose


configure do
  enable :sessions
  set :session_secret, 'secret'
  set :font_family, 'sans-serif'
  set :erb, :escape_html => true
end

helpers do

end

before do

end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def initialize_contact_list(username)
  File.open(File.join(data_path, "#{username}.yml"), "w") do |file| 
    file.write("{}")
  end
end

def load_contacts(username)
  YAML.load_file(File.join(data_path, "#{username}.yml"))
end

get '/' do
  erb :index, layout: :layout
end

get '/users/:username/contacts' do
  @username = params[:username]
  redirect '/' unless username
  erb :index, layout: :layout
end

get '/users/signin' do
  erb :sign_in, layout: :layout
end

post '/users/signin' do
  username = params[:username]
  password = params[:password]
  
  if authenticate(username, password)
    session[:success] = "Welcome #{username}!"
    session[:username] = username
    session[:contacts] = load_contacts(username)
    redirect '/'
  else
    session[:error] = "Invalid Credentials"
    redirect '/users/signin'
  end
end

post '/users/signout' do
  session[:username] = nil
  session[:success] = "Successfully signed out"
  redirect '/'
end

get '/users/signup' do
  erb :sign_up, layout: :layout
end

post '/users/signup' do
  username = params[:username]
  password = params[:password]
  users = load_user_credentials
  
  if valid_credentials(username, password)
    hashed_pw = BCrypt::Password.create(password).to_str
    users[username] = hashed_pw
    File.open(credentials_path, "w") { |file| file.write(users.to_yaml) }
    initialize_contact_list(username)
    session[:success] = "#{username} successfully signed up! Please sign in below"
    redirect '/'
  else
    session[:error] = "Invalid Credentials"
    redirect '/users/signup'
  end
end

get '/users/:username/contacts/add' do
  @username = params[:username]
  
  erb :add, layout: :layout
end

post '/users/:username/contacts/add' do
  @username = params[:username]
  
  redirect '/users/:username/contacts'
end