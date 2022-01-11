# frozen_string_literal: true

require_relative 'autoload'
require 'delegate'

use Rack::Reloader, 0
use Rack::Static, urls: ['/assets'], root: 'lib/views'
use Rack::Session::Cookie, key: 'rack.session', secret: 'secret'

run Lib::Source::Router
