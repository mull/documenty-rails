require 'yard'

module DocumentyRails
  class ControllerParser
    def self.parse(controller_object)
      # We ignore classes that aren't resources
      return nil unless controller_object.has_tag? :resource

      name = controller_object.tag(:resource).text.downcase

      # Fetch methods/actions
      resource_actions = {}
      controller_object.children.each do |method|
        next unless method.visibility == :public
        method_name = method.name.to_s
        actions = {
          'path' => method.tag(:path).text,
          'description' => method.docstring.to_s,
          'parameters' => {}
        }

        if method.has_tag? :param
          method.tags(:param).each do |param|
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

      return [name, resource]
    end
  end
end