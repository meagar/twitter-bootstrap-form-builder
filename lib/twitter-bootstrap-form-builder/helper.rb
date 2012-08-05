
module MNE
  module TwitterBootstrapFormBuilder
    module Helper
      def form_for (record, options = {}, &proc)
        return super(record, options, &proc) if options.delete(:bootstrap) === false

        options[:builder] ||= MNE::TwitterBootstrapFormBuilder::FormBuilder
        options[:html] ||= {}
        options[:html][:class] ||= ""

        if !options[:html][:class].match(/form-(horizontal|vertical)/)
          options[:html][:class] = ["form-horizontal", options[:html][:class]].join(" ")
        end

        super(record, options, &proc)
      end
    end
  end
end

