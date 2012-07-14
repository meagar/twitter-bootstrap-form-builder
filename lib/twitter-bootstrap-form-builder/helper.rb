
module MNE
  module TwitterBootstrapFormBuilder
    module Helper
      def form_for (*args)
        args << {} unless args.last.is_a? Hash

        args.last[:builder] ||= MNE::TwitterBootstrapFormBuilder::FormBuilder
        args.last[:html] ||= {}
        args.last[:html][:class] ||= ""

        if !args.last[:html][:class].match(/form-(horizontal|vertical)/)
          args.last[:html][:class] = ["form-horizontal", args.last[:html][:class]].join(" ")
        end

        super
      end
    end
  end
end

