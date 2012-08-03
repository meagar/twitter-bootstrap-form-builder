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

        opts[:class] << "error" if @object.errors.messages.has_key?(field) && @object.errors.messages[field].any?

        @template.content_tag(:div, opts) do
          @template.capture &block
        end
      end

      %w(text_field phone_field password_field email_field number_field file_field text_area select).each do |method_name|
        define_method method_name.to_sym do |field, *args|

          # find the options hash, and extract the options for the label tag
          opts       = extract_options(args)
          label_opts = extract_sub_options(opts, :label)

          # If label is false, we're rendering the field without modification
          return super(field, *args) if label_opts === false

          # Add the TB class to the label
          label_opts << { :class => "control-label" }

          # create a help-block if present
          help_block = opts[:help_block] ? @template.content_tag(:p, opts[:help_block], :class => "help-block") : ""

          # propogate properties of control group up
          control_group_opts = opts[:control_group] || {}
          control_group_opts[:class] = control_group_opts[:class] ? control_group_opts[:class] + " #{method_name}" : "#{method_name}"

          control_group(field, control_group_opts) do
            label(field, *label_opts) + @template.content_tag(:div, :class => "controls") do
              super(field, *args) + help_block + errors_for(field)
            end
          end.html_safe
        end
      end


      # Special handling for check boxes, which can have two labels
      def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
        label_opts = extract_sub_options(options, :label)
        about_opts = extract_sub_options(options, :about)

        return super if label_opts == false

        #raise [object.errors.messages, errors_for(field)].inspect
        # Add the TB class to the thelabel
        label_opts << { :class => "control-label" } unless label_opts.nil?
        about_opts << { :class => "checkbox" } if about_opts.any?

        control_group_opts = options[:control_group] || {}

        label_tag = (label_opts ? label(field, *label_opts) : "").html_safe
        check_box = super(field, options, checked_value, unchecked_value).html_safe

        control_group(field, control_group_opts) do
          label_tag + @template.content_tag(:div, :class => "controls") do
            check_box = label(field, *about_opts) { check_box + about_opts[0] } if about_opts
            check_box + errors_for(field)
          end
        end.html_safe
      end

      protected

      def extract_options(args)
        args.find { |a| a.is_a?(Hash) && a.has_key?(:label) } || {}
      end

      def extract_sub_options(opts, key = :label)
        sub_opts = opts.keys.include?(key) ? opts.delete(key) : []
        return false if sub_opts === false
        return nil   if sub_opts.nil?
        Array(sub_opts)
      end

      def label_opts(opts, key = :label)
        label_opts = extract_sub_options(opts, key)
        label_opts << { :class => "control-label" }
      end

      def errors_for(field)
        @template.content_tag(:span, "#{object.class.human_attribute_name(field)} #{object.errors.messages[field].to_sentence}",
                              :class => "help-inline") if object.errors.messages.has_key?(field) && object.errors.messages[field].any?
      end

    end
  end
end
