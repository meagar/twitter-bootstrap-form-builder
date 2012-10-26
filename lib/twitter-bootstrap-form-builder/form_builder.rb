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

        opts[:class] << field.to_s.gsub(/[^-_a-zA-Z0-9]/, "") if field

        opts[:class] << "error" if @object && @object.errors.messages.has_key?(field) && @object.errors.messages[field].any?

        @template.content_tag(:div, opts) do
          @template.capture &block
        end
      end

      # Wrappers around the various *_fields method which include the markup needed
      # to make a pretty Twitter Bootstrap form
      #
      # Options:
      #   :label => ...
      #     String - Specify the text of the label
      #     Array  - Specify all arguments to pass to label_tag
      #     nil    - No label, but maintain the rest of the Bootstrap markup
      #     false  - Fallback to FormBuilder's implementation (no Bootstrap markup at all)
      #   :help_block => String - Add help sub-text to the field
      %w(text_field phone_field password_field email_field number_field file_field text_area select collection_select date_select datetime_select time_select).each do |method_name|
        define_method method_name.to_sym do |field, *args|

          # find the options hash, and extract the options for the label tag
          opts = extract_options(args)

          label_tag = build_label_tag(field, opts)

          # If label is false, we're rendering the field without modification
          return super(field, *args) if label_tag === false

          # create a help-block if present
          help_block = opts[:help_block] ? @template.content_tag(:p, opts.delete(:help_block), :class => "help-block") : ""

          # propogate properties of control group up
          control_group_opts = opts[:control_group] || {}
          control_group_opts[:class] = "#{control_group_opts[:class]} #{method_name}"

          control_group(field, control_group_opts) do
            label_tag + @template.content_tag(:div, :class => "controls") do
              super(field, *args) + help_block + errors_for(field)
            end
          end.html_safe
        end
      end


      # Special handling for check boxes, which can have two labels
      #
      # Options
      #   :label - As the *_field methods
      #   :text - Like :label but for the right-hand label
      def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
        label_tag = build_label_tag(field, options)

        return super if label_tag === false

        control_group_opts = options[:control_group] || {}

        options[:text] ||= false

        control_group(field, control_group_opts) do
          label_tag + @template.content_tag(:div, :class => "controls") do

            opts = options.clone
            opts[:text] = nil
            check_box_tag = super(field, opts, checked_value, unchecked_value).html_safe

            text_tag = build_label_tag(field, options, :text, {:class => "checkbox"}) do |opts|
              "#{check_box_tag} #{opts[0]}".html_safe
            end

            text_tag ||= @template.content_tag(:label, check_box_tag, :class => "checkbox")

            text_tag.html_safe + errors_for(field)
          end.html_safe
        end.html_safe
      end

      # Very light wrapper around FormBuilder#submit which adds a 'btn' class
      #
      # Options:
      #   :label => false - fall back to FormBuilder#submit
      #   :primary => true - add btn-primary class
      def submit(value = nil, options = {})

        if options[:label] === false
          options.delete(:label)
          return super
        end

        options[:class] = "#{options[:class]} btn"
        options[:class] = "#{options[:class]} btn-primary" if options.delete(:primary)

        super(value, options)
      end

      protected

      def extract_options(args)
        args.find { |a| a.is_a?(Hash) } || {}
      end

      # Build a label tag (or return false, or "") based on the rules for passing
      # nil/false/a string/an array/a hash into the options hash
      def build_label_tag(field, opts, key = :label, defaults = { :class => "control-label" }, &block)
        label_opts = extract_sub_options(opts, key, defaults)

        # False indicates complete fall-back to FormBuilder's implementation
        return false if label_opts === false

        if label_opts
          if block_given?
            label(field, *label_opts) { yield(label_opts) }
          else
            label(field, *label_opts)
          end
        else
          ""
        end.html_safe
      end

      # Pull nested (label) options out of an options hash
      # Used primarily by checkbox's :label/:text tags
      def extract_sub_options(opts, key = :label, defaults = {})
        if opts.keys.include?(key)
          sub_opts = opts.delete(key)

          return [defaults.merge(sub_opts)] if sub_opts.is_a? Hash
          return [sub_opts, defaults] if sub_opts.is_a? String

          # If we were explicitly given an array, we're done.
          # Freeze it, and pass it directly to label_tag
          if sub_opts.is_a? Array
            sub_opts.freeze
            return sub_opts
          end

          # If the user explicitly passed in nil, return it
          return nil if sub_opts.nil?
        end

        return false if sub_opts === false

        sub_opts || [defaults]
      end

      #def label_opts(opts, key = :label)
      #  label_opts = Array(extract_sub_options(opts, key))
      #  label_opts << { :class => "control-label" }
      #end

      def errors_for(field)
        @template.content_tag(:span, "#{object.class.human_attribute_name(field)} #{object.errors.messages[field].to_sentence}",
                              :class => "help-inline") if object && object.errors.messages.has_key?(field) && object.errors.messages[field].any?
      end

    end
  end
end
