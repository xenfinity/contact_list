def credentials_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
end

def authenticate(username, password)
  users = load_user_credentials
  stored_hash = users[username]

  hashed_pw = BCrypt::Password.new(stored_hash) if stored_hash
  hashed_pw == password
end

def load_user_credentials
  YAML.load_file(credentials_path)
end

def valid_credentials(username, password)
  valid_username?(username) && valid_password?(password)
end

def valid_username?(username)
  users = load_user_credentials
  if username.size < 3
    session[:error] = "Username is too short, must be at least 3 characters long."
    redirect '/users/signup'
  elsif users.keys.include?(username)
    session[:error] = "Username already exists."
    redirect '/users/signup'
  else
    true
  end
end

def valid_password?(password)
  if password.size < 8
    session[:error] = "Password is too short, must be at least 8 characters long."
    redirect '/users/signup'
  elsif password.match?(/^([^A-Z]*|[^a-z]*|[^\d]*)$/)
    session[:error] = "Password must contain at least one uppercase letter, lowercase letter and number"
    redirect '/users/signup'
  else
    true
  end
end

def user_signed_in?(session)
  session[:username]
end

def redirect_protected_content(session)
  unless user_signed_in?(session)
    session[:error] = "You must be signed in to do that."
    redirect '/'
  end
end

