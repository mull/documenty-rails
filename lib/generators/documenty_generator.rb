require 'rails/generators/named_base'
require 'documenty'
require 'yard'
require 'yaml'
require 'documenty-rails/controller_parser'
require 'documenty-rails/yard_tags'

module Documenty
  module Generators
    class DocumentyGenerator < ::Rails::Generators::Base

      desc <<-DESC
Description:
    Copy rspec files to your application.
DESC

      def create_api_docs_from_controllers
        puts "LOWL"
        DocumentyRails::TAGS.each do |tag|
          YARD::Tags::Library.define_tag(tag[0], tag[1])
        end

        files = Dir.glob( File.join(Rails.root, 'app/controllers/api/**/*controller.rb') )

        files.each do |file|
          YARD.parse(file)
        end

        config_file = File.join(Rails.root, 'config/documenty.yml')
        output_directory = File.join(Rails.root, 'public/api')

        base = {}
        if File.exists? config_file
          base = YAML.load( File.open(config_file) )["base"]
        else
          puts <<-RUN_INSTALLER
            Please run the documenty-rails installer by issuing the command "rails g documenty:install"
          RUN_INSTALLER
          exit
        end

        resources = {}
        YARD::Registry.all(:class).each do |klass|
          resource = DocumentyRails::ControllerParser.parse(klass)
          resources[resource[0]] = resource[1] unless resource.nil?
        end

        api = {
          "base" => base,
          "resources" => resources
        }

        yml_file = File.join(output_directory, 'api.yml')

        # Create the directories necessary to create our output
        # TODO: Handle exceptions
        FileUtils::mkdir_p( File.dirname(yml_file) )

        # Write our documentation to file
        File.open(yml_file, "w+") do |out|
          YAML.dump(api, out)
        end


        # Use YamlAPIParser to guarantee that we made a correct YAML file
        yap = Documenty::YamlAPIParser.new(yml_file)

        # Use HTMLParser in much the same way that Documenty does
        html_file = File.join( output_directory, 'index.html' )
        if yap.valid?
          Documenty::HTMLProducer.produce(yap.attributes, html_file)
        else
          puts "I could not produce HTML :-/"
        end
      end
    end
  end
end