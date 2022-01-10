# frozen_string_literal: true

RSpec.describe Lib::Source::Router do
  def app
    Rack::Builder.parse_file('./config.ru').first
  end

  let(:name) { 's' * Codebreaker::Constant::MIN_NAME_LENGTH }
  let(:game) { Codebreaker::Game.new(name) }
  let(:guess_number) { Codebreaker::Constant::MIN_CODE_VALUE.to_s * Codebreaker::Constant::CODE_SIZE }

  describe 'access to simple URLs with no activity' do
    context 'when gets to /' do
      before { get Lib::Source::Router::ROUTES[:main] }

      it 'receives the status 200' do
        expect(last_response.status).to be(200)
      end

      it 'receives display Codebreaker 2020 on page' do
        expect(last_response.body).to include(I18n.t(:page_title))
      end
    end

    context 'when gets unknown page' do
      before { get '/unknown' }

      it 'receives the status 404' do
        expect(last_response.status).to be(404)
      end

      it 'receives page 404' do
        expect(last_response.body).to include(I18n.t(:not_found_page_message))
      end
    end

    context 'when gets statistics url' do
      before { get Lib::Source::Router::ROUTES[:statistics] }

      it 'receives statistics title' do
        expect(last_response.body).to include I18n.t('statistics.title')
      end
    end

    context 'when get rules url' do
      before { get Lib::Source::Router::ROUTES[:rules] }

      it 'receives rules title' do
        expect(last_response.body).to include I18n.t('rules_page.title')
      end
    end
  end

  describe 'access to game url with entered name and difficulty' do
    before do
      env 'rack.session', game: game
      post Lib::Source::Router::ROUTES[:game], player_name: name
    end

    context 'when the user just entered the game' do
      it 'receives hint button' do
        expect(last_response.body).to include(Lib::Source::Router::ROUTES[:hint])
      end

      it 'receives welcome message with user`s name' do
        expect(last_response.body).to include I18n.t('game_page.welcome_message', name: name)
      end
    end
  end

  describe 'some action on game page' do
    context 'when user tries to guess once' do
      before do
        game.use_attempts(guess_number)
        env 'rack.session', game: game
        get Lib::Source::Router::ROUTES[:check_guess], game: game
      end

      it 'receives field with quantity remaining user attempts' do
        expect(last_response.body).to include(game.users_attempts.to_s)
      end
    end

    context 'when user takes hint first rime' do
      before do
        game.use_hint
        env 'rack.session', game: game
        get Lib::Source::Router::ROUTES[:hint], game: game
      end

      it 'receives a field with hint' do
        expect(last_response.body).to include(game.users_hints.to_s)
      end

      it 'receives a field with the number of hints' do
        expect(last_response.body).to include((game.difficulty.hints - 1).to_s)
      end
    end

    context 'when user takes a second hint' do
      before do
        2.times { game.use_hint }
        env 'rack.session', game: game
        get Lib::Source::Router::ROUTES[:hint], game: game
      end

      it 'receives a field with hint' do
        expect(last_response.body).to include(game.users_hints.to_s)
      end

      it 'receives a field with the number of hints' do
        expect(last_response.body).to include((game.difficulty.hints - 2).to_s)
      end
    end
  end

  describe 'lose and win events' do
    context 'when user lose' do
      before do
        env 'rack.session', game: game
        15.times { post Lib::Source::Router::ROUTES[:check_guess], number: guess_number }
      end

      it 'receives lose_message on lose_page with user`s name' do
        expect(last_response.body).to include(I18n.t('lose_page.lose_message', name: game.user))
      end
    end

    context 'when user win' do
      let(:secret_code) { game.secret_code }

      before do
        env 'rack.session', game: game
        post Lib::Source::Router::ROUTES[:check_guess], number: secret_code
      end

      it 'receives congratulations message on win_page with user`s name' do
        expect(last_response.body).to include(I18n.t('win_page.congratulations', name: game.user))
      end
    end
  end

  describe 'when user enters invalid data' do
    context 'with invalid name (less than 3 symbols)' do
      let(:name) { 's' * (Codebreaker::Constant::MIN_NAME_LENGTH - 1) }

      before do
        post Lib::Source::Router::ROUTES[:game], player_name: name
      end

      it 'receive error about name length' do
        expect(last_response.body).to include('Name length must be between 3 and 20')
      end
    end

    context 'with invalid code (less than 4 symbols)' do
      let(:invalid_guess_number) { Codebreaker::Constant::MIN_CODE_VALUE.to_s * (Codebreaker::Constant::CODE_SIZE - 1) }

      before do
        env 'rack.session', game: game
        post Lib::Source::Router::ROUTES[:check_guess], number: invalid_guess_number
      end

      it 'receive error about code length' do
        expect(last_response.body).to include('The entered code must be in the format: 4 digits')
      end
    end
  end
end
