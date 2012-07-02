== SETUP

setup your myneu username / password locally under `config/initializers/dev_enviornment.rb`

```
unless Rails.env.production?
  ENV['MYNEU_USERNAME'] = 'username'
  ENV['MYNEU_PASSWORD'] = 'password'
end
```
