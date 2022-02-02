# frozen_string_literal: true

module Lib
  module Source
    class Router
      ROUTES = {
        main: '/',
        game: '/game',
        check_guess: '/check_guess',
        hint: '/hint',
        statistics: '/statistics',
        rules: '/rules',
        win: '/win',
        lose: '/lose'
      }.freeze

      def self.call(env)
        new(env).response.finish
      end

      def initialize(env)
        @env = env
        @request = Rack::Request.new(env)
        @errors = []
      end

      def response
        return Rack::Response.new(I18n.t('not_found_page_message'), 404) unless ROUTES.value?(@request.path)

        @request.session[:game] ? Lib::Source::GameResponse.call(@request) : Lib::Source::MenuResponse.call(@request)
      end
    end
  end
end
