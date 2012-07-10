module DocumentyRails
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      desc <<DESC
Description:
    Copy rspec files to your application.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def say_hi
        puts "I need some basic information to create your API documentation."
        print "API name: "; name = STDIN.readline.strip
        print "API version: "; version = STDIN.readline.strip
        print "API url: "; url = STDIN.readline.strip

        config = {
          "base" => {
            "name" => name,
            "version" => version,
            "url" => url
          }
        }

        create_file "config/documenty.yml", YAML.dump(config)
      end

    end
  end
end