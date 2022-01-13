# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.3'
gem 'bundler', '>= 1.17.2'
gem 'codebreaker', git: 'https://github.com/believerfenix/codebreaker.git', branch: 'dev'
gem 'haml', '~> 5.2'
gem 'i18n', '~> 1.8.9'
gem 'rack', '~> 2.2.3'
gem 'shotgun', '~>0.9.2'
gem 'pry', '~> 0.14.0'

group :development do
  gem 'fasterer', '~> 0.9.0'
  gem 'lefthook', '~> 0.7.2'
  gem 'rubocop', '~> 1.12.0', require: false
  gem 'solargraph', '~> 0.40.4'
end

group :test do
  gem 'faker', '~> 2.17'
  gem 'rack-test', '~> 1.1.0', group: :test
  gem 'rspec', '~> 3.8'
  gem 'rubocop-rspec', '~> 2.2.0', require: false
  gem 'simplecov', '~> 0.21.2'
  gem 'simplecov-lcov', '~> 0.8.0'
end
