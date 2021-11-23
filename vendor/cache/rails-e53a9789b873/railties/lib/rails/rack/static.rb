require 'rack/utils'

module Rails
  module Rack
    class Static
      FILE_METHODS = %w(GET HEAD).freeze

      def initialize(app)
        @app = app
        @file_server = ::Rack::File.new(File.join(RAILS_ROOT, "public"))
      end

      def call(env)
        path        = env['PATH_INFO'].chomp('/')
        method      = env['REQUEST_METHOD']

        if FILE_METHODS.include?(method)
          if file_exist_within_root?(path)
            return @file_server.call(env)
          else
            cached_path = directory_exist?(path) ? "#{path}/index" : path
            cached_path += ::ActionController::Base.page_cache_extension

            if file_exist_within_root?(cached_path)
              env['PATH_INFO'] = cached_path
              return @file_server.call(env)
            end
          end
        end

        @app.call(env)
      end

      private

        PATH_SEPS = Regexp.union(*[::File::SEPARATOR, ::File::ALT_SEPARATOR].compact)

        def clean_path_info(path_info)
          parts = path_info.split PATH_SEPS

          clean = []

          parts.each do |part|
            next if part.empty? || part == '.'
            part == '..' ? clean.pop : clean << part
          end

          clean.unshift '/' if parts.empty? || parts.first.empty?

          ::File.join(*clean)
        end

        def file_exist_within_root?(path)
          full_path = File.join(@file_server.root, clean_path_info(::Rack::Utils.unescape(path)))
          File.file?(full_path) && File.readable?(full_path)
        end

        def directory_exist?(path)
          full_path = File.join(@file_server.root, ::Rack::Utils.unescape(path))
          File.directory?(full_path) && File.readable?(full_path)
        end
    end
  end
end
