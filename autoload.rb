# frozen_string_literal: true

require 'codebreaker'

require 'haml'
require 'bundler/setup'
require 'rack'
require 'i18n'
require_relative 'I18nconfig/config'

require_relative 'lib/modules/views'
require_relative 'lib/source/game_response'
require_relative 'lib/source/menu_response'
require_relative 'lib/source/router'
