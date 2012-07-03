# SETUP

setup your myneu username / password locally under `config/initializers/dev_environment.rb`
```
unless Rails.env.production?
  ENV['MYNEU_USERNAME'] = 'username'
  ENV['MYNEU_PASSWORD'] = 'password'
end
```
# REFERENCES
* nokogiri (HTML parser) http://hunterpowers.com/data-scraping-and-more-with-ruby-nokogiri-sinatra-and-heroku/
* mechanize general doc http://mechanize.rubyforge.org/Mechanize.html
* mechanize examples http://mechanize.rubyforge.org/EXAMPLES_rdoc.html
