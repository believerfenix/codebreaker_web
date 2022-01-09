# frozen_string_literal: true

module Lib
  module Source
    class GameResponse
      include Lib::Modules::Views

      NO_MATCH = 'x'

      def self.call(env)
        new(env).response
      end

      def initialize(request)
        @request = request
        @game = @request.session[:game]
        @guess_number = @request.session[:guess_number]
        @guess_result = @request.session[:result]
        @hints = @request.session[:hints]
        @errors = []
      end

      def response
        case @request.path
        when Router::ROUTES[:check_guess] then check_guess
        when Router::ROUTES[:hint] then hint
        when Router::ROUTES[:lose] then lose
        when Router::ROUTES[:win] then win
        else redirect_to(:game)
        end
      rescue Codebreaker::Errors::CheckCodeLengthError, Codebreaker::Errors::CheckCodeValueError => e
        assign_error(e)
      end

      def check_guess
        return redirect_to(:game) unless @request.params['number']

        @guess_number = @request.params['number']
        @request.session[:guess_number] = @guess_number
        enter_guess
        return win if @game.win?(@request.params['number'])
        return lose if @game.lose?

        convert_result
      end

      def lose
        return redirect_to(:game) if game_active? && !@game.lose?

        @request.session.clear
        redirect_to(:lose)
      end

      def win
        return redirect_to(:game) if game_active? && !@game.win?(@request.params['number'])

        @game.save_statistic
        @request.session.clear
        redirect_to(:win)
      end

      def hint
        @hints = @request.session[:hints] || []
        if @game.users_hints.positive?
          @hints << @game.use_hint
          @request.session[:hints] = @hints
        end
        redirect_to(:game)
      end

      private

      def enter_guess
        @guess_result = @game.use_attempts(@guess_number.to_s).dup
        @request.session[:guess_result] = @guess_result
      end

      def convert_result
        (4 - @guess_result.size).times { @guess_result << NO_MATCH }
        @request.session[:result] = @guess_result
        redirect_to(:game)
      end

      def assign_error(errors)
        @errors << errors.message
        render_page(Lib::Modules::Views::TEMPLATES[:game])
      end

      def game_active?
        @request.session[:game]
      end
    end
  end
end
