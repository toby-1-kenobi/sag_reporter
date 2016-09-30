class PaperFormBuilder < ActionView::Helpers::FormBuilder

  def paper_text_field(method, options = {})
    PaperTextField.new(@object_name, method, @template, options).render
  end

  class PaperTextField < ActionView::Helpers::Tags::Base

    def initialize(object_name, method_name, template_object, options = {})
      super(object_name, method_name, template_object, options)
    end

    def render
      options = @options.stringify_keys
      options['maxlength'] = options['size'] unless options.key?('maxlength')
      options['value'] = options.fetch('value') { value_before_type_cast(object) }
      options['value'] ||= "didn't get value!"
      options['label'] = @method_name.humanize
      add_default_name_and_id(options)
      tag('paper-input', options)
    end

  end

end