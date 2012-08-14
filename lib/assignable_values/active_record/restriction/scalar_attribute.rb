module AssignableValues
  module ActiveRecord
    module Restriction
      class ScalarAttribute < Base

        def initialize(*args)
          super
          define_humanized_method
        end

        def humanize_value(value)
          if value.present?
            if @hardcoded_humanizations
              @hardcoded_humanizations[value]
            else
              dictionary_scope = "assignable_values.#{model.name.underscore}.#{property}"
              I18n.t(value.to_s, :scope => dictionary_scope, :default => value.humanize)
            end
          end
        end

        private

        def parse_values(values)
          if values.is_a?(Hash)
            @hardcoded_humanizations = values
            values = values.keys
          else
            super
          end
        end

        def define_humanized_method
          restriction = self
          enhance_model do
            define_method "humanized_#{restriction.property}" do |*args|
              given_value = args[0]
              value = given_value || send(restriction.property)
              restriction.humanize_value(value)
            end
          end
        end

        def decorate_values(values)
          restriction = self
          values.collect do |value|
            value = value.dup
            value.singleton_class.send(:define_method, :humanized) do
              restriction.humanize_value(value)
            end
            value
          end
        end

        def previously_saved_value(record)
          record.send("#{property}_was")
        end

      end
    end
  end
end
