# frozen_string_literal: true

module Lib
  module Modules
    module Views
      VIEWS_PATH = 'lib/views/'
      HAML_EXTENSION = '.html.haml'
      LAYOUT = 'layout'
      PARTIALS_PATH = 'partials/'

      TEMPLATES = {
        lose: 'lose',
        win: 'win',
        statistics: 'statistics',
        rules: 'rules',
        game: 'game',
        menu: 'menu'
      }.freeze

      def redirect_to(templates)
        Rack::Response.new(render_page(TEMPLATES[templates.to_sym]))
      end

      def render(template)
        path = File.read(filename_path(template))
        Haml::Engine.new(path).render(binding)
      end

      def render_page(template)
        Rack::Response.new(render(LAYOUT) { render(template) })
      end

      def render_partial(template)
        render(PARTIALS_PATH + template)
      end

      def filename_path(template)
        File.expand_path("#{VIEWS_PATH}#{template}#{HAML_EXTENSION}")
      end
    end
  end
end
