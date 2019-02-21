require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
enable :sessions

get('/') do
    slim(:index)
end

get('/sign_up') do
    slim(:sign_up)
end 

post('/sign_up') do
    db = SQLite3::Database.new("db/bloggdatabas.db")
    db.results_as_hash = true

    existing_user = db.execute("SELECT username FROM user_login WHERE username=?", params["username"])

    if existing_user.length > 0
        redirect(:sign_up)
    end

    password = BCrypt::Password.create(params['password'])

    db.execute("INSERT INTO user_login(username, password) VALUES (?, ?)", [params["username"], password])

    redirect('/')
end

get('/login') do
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/bloggdatabas.db")
    db.results_as_hash = true
    
    existing_user = db.execute("SELECT password FROM user_login WHERE username=?",[params["username"]])

    if existing_user.length == 0
        redirect(:login)
    end

    password_hash = existing_user[0]["password"]

    password_match = BCrypt::Password.new(password_hash) == params["password"]

    if password_match
        session[:username] = params["username"]
        redirect("/profile/#{params["username"]}")
    else
        redirect(:login)
    end
end

get('/profile/:username') do
    slim(:profile, locals:{user:params["username"]})
end