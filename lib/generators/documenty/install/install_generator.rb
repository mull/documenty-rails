module Documenty
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      desc <<-DESC
Description:
    Create the config/documenty.yml configuration file by giving
    documenty-rails some basic information about your API.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def generate_config
        puts "I need some basic information to create your API documentation."
        print "API name: "; name = STDIN.readline.strip
        print "API version: "; version = STDIN.readline.strip
        print "API url: "; url = STDIN.readline.strip
        print "API controller namespace (eg. api/v1): "
        # TODO: handle trailing /
        namespace = STDIN.readline.strip


        config = {
          "config" => {
            "controller_namespace" => namespace
          },

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