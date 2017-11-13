# standard-radiators
Built with Sinatra

### To run the app

- git clone.
- Run `bundle install`
- Run `ruby app.rb` in the terminal
- visit `localhost:4567/reset` to setup the db.
Admin login endpoint `http://localhost:4567/signin`. You'll have to add an admin account using the rails console



Authentication is in credentials.yml. To generate new password hash, open ruby console, `require './app.rb'`, then `include BCrypt`, then `Password.create('newpassword')`. Copy the generated hash into credentials.yml. Easy peasy.

We're manually rendering the css file using `sass --watch views/css/main.scss:public/css/main.css`. Feel free to use other methods to update that file.
