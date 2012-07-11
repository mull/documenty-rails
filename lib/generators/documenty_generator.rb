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
    Generate an API documentation from your API controllers.
DESC
      source_root( File.expand_path("../../../static/", __FILE__))

      def create_api_docs_from_controllers
        DocumentyRails::TAGS.each do |tag|
          YARD::Tags::Library.define_tag(tag[0], tag[1])
        end


        config_file = File.join(Rails.root, 'config/documenty.yml')
        output_directory = File.join(Rails.root, 'public/api')

        if File.exists? config_file
          config = YAML.load( File.open(config_file) )
          validate_required_configuration(config)
        else
          puts 'Please run the documenty-rails installer by issuing the command "rails g documenty:install"'
          exit
        end

        api = {
          "base" => config["base"]
        }

        namespace = config["config"]["controller_namespace"]
        namespace_regex = Regexp.new(namespace)

        resources = {}

        # Scan through routes and look for our namespace
        Rails.application.routes.routes.each do |route|
          if namespace_regex =~ route.path.spec.to_s
            controller = route.defaults[:controller]
            method = route.defaults[:action]
            controller_file = "#{route.defaults[:controller]}_controller.rb"
            controller_path = File.join(Rails.root, 'app/controllers', controller_file)

            # Safety check :-P
            next unless File.exists? controller_path
            
            resource_name = controller.split('/').last.singularize
            resources[resource_name] ||= {}
            resources[resource_name]["actions"] ||= {}

            action = {
              "path" => route.path.spec.to_s,
              "method" => /[^\^\$\/]+/.match(route.verb.inspect)[0]
            }

            resources[resource_name]["actions"][method] = action
            YARD.parse(controller_path)
          end
        end
      

        YARD::Registry.all(:class).reverse.each do |klass|
          docs = DocumentyRails::ControllerParser.parse(klass)
          unless docs.nil?
            name = klass.name.to_s.split('Controller')[0].singularize.downcase
            resources[name].deep_merge!(docs)
          end
          #resources[resource[0]] = resource[1] unless resource.nil?
        end        

        puts "Done parsing #{YARD::Registry.all(:class).count} classes..."
        api["resources"] = resources        

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

        if yap.valid?
          Documenty::HTMLProducer.produce(yap.attributes, output_directory)
          copy_file "style.css", File.join(output_directory, 'style.css')
        else
          puts "I could not produce HTML :-/"
        end
      end

      private
      def validate_required_configuration(config)
        required_base = ["name", "version", "url"]

        if config["base"].nil? || config["base"].empty?
          puts "Config file does not contain base properties, exiting..."
          exit
        end

        required_base.each do |base_attr|
          if config["base"][base_attr].nil? || config["base"][base_attr].blank?
            puts "Config file does not contain the required attribute '#{base_attr}', exiting..."
            exit
          end
        end

        if !config["config"].nil? && !config["config"].empty? 
          if config["config"]["controller_namespace"].nil?
            puts "There is no controller namespace set, exiting..."
            exit
          end
        else
          puts "There is no configuration set, exiting..."
          exit
        end
      end
    end
  end
end