
require 'dynamic_form'

module MNE
  module TwitterBootstrapFormBuilder
    class FormBuilder < ActionView::Helpers::FormBuilder

      include ActionView::Helpers::DynamicForm::FormBuilderMethods

      def control_group(field = nil, opts = {}, &block)
        raise "Expected hash for options, got #{opts.inspect}" unless opts.is_a? Hash

        # wrap in array if not an array
        opts[:class] = Array(opts[:class])
        opts[:class] << "control-group"
        opts[:class] << field if field

        opts[:class] << "error" if @object.errors.messages.has_key? field

        @template.content_tag(:div, opts) do
          @template.capture &block
        end
      end

      %w(text_field phone_field password_field email_field number_field file_field text_area select).each do |method_name|
        define_method method_name.to_sym do |field, *args|

          # extract the options for the label tag
          opts = args.find { |a| a.is_a?(Hash) && a.has_key?(:label) }
          label_opts = opts ? opts[:label] : []

          # If label is false, we're rendering the field without modification
          return super (field, *args) if label_opts === false

          label_opts = Array[label_opts] << { :class => "control-label" }

          control_group(field, :class => "#{method_name}") do
            label(field, *label_opts) + @template.content_tag(:div, :class => "controls") do
              super(field, *args) + errors_for(field)
            end
          end.html_safe
        end

      end

      def errors_for(field)
        @template.content_tag(:p, "#{object.class.human_attribute_name(field)} #{object.errors.messages[field].join(",")}",
                              :class => "help-block") if object.errors.messages[field].any?
      end

    end
  end
end
