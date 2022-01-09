# frozen_string_literal: true

module Lib
  module Source
    class MenuResponse
      include Lib::Modules::Views

      def self.call(env)
        new(env).response
      end

      def initialize(request)
        @request = request
        @errors = []
      end

      def response
        case @request.path
        when Router::ROUTES[:main] then menu
        when Router::ROUTES[:statistics] then statistics
        when Router::ROUTES[:rules] then rules
        when Router::ROUTES[:game] then registration
        else redirect_to(:menu)
        end
      rescue Codebreaker::Errors::CheckNameLengthError, Codebreaker::Errors::CheckCodeLengthError => e
        assign_error(e)
      end

      def menu
        @request.session.clear

        redirect_to(:menu)
      end

      def registration
        return redirect_to(:menu) unless @request.params['player_name']

        @name = @request.params['player_name']
        difficulty = @request.params['level']
        @game = Codebreaker::Game.new(@name, difficulty)
        @request.session[:game] = @game
        redirect_to(:game)
      end

      def statistics
        redirect_to(:statistics)
      end

      def rules
        redirect_to(:rules)
      end

      def assign_error(errors)
        @errors << errors.message
        render_page(Lib::Modules::Views::TEMPLATES[:menu])
      end
    end
  end
end
