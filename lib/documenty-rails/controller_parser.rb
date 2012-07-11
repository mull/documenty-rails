require 'yard'

module DocumentyRails
  class ControllerParser
    def self.parse(controller_object)
      # Fetch methods/actions
      resource_actions = {}
      controller_object.children.each do |method|
        next unless method.visibility == :public
        method_name = method.name.to_s
        actions = {}

        actions['description'] = method.docstring.to_s unless method.docstring.empty?

        if method.has_tag? :param
          method.tags(:param).each do |param|
            actions['parameters'] ||= {}
            param_name = param.name.gsub(':', '')
            actions['parameters'][param_name] = param.text
          end
        end
        
        resource_actions[method_name] = actions
      end

      resource = {
        'description' => controller_object.docstring.to_s,
        'actions' => resource_actions
      }

      return resource
    end
  end
end