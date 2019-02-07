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
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    existing_user = db.execute("SELECT username FROM user_login WHERE username=?", params["username"])

    if existing_user.length > 0
        redirect(:sign_up)
    end

    password = BCrypt::Password.create(params['password'])

    db.execute("INSERT INTO user_login(username, password) VALUES (?, ?)", [params["username"], password])

    redirect('/users')
end