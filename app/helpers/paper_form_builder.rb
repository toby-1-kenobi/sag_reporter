require 'json'

class PaperFormBuilder < ActionView::Helpers::FormBuilder

  def paper_text_field(method, options = {})
    PaperTextField.new(@object_name, method, @template, options).render
  end

  def paper_autocomplete(method, options = {})
    PaperAutocomplete.new(@object_name, method, @template, options).render
  end

  def paper_textarea(method, options = {})
    PaperTextArea.new(@object_name, method, @template, options).render
  end

  class PaperTextField < ActionView::Helpers::Tags::Base

    def initialize(object_name, method_name, template_object, options = {})
      super(object_name, method_name, template_object, options)
    end

    def render
      options = @options.stringify_keys
      options['maxlength'] = options['size'] unless options.key?('maxlength')
      options['value'] = options.fetch('value') { value_before_type_cast(object) }
      options['label'] ||= @method_name.humanize
      add_default_name_and_id(options)
      tag('paper-input', options)
    end

  end

  class PaperTextArea < ActionView::Helpers::Tags::Base

    def initialize(object_name, method_name, template_object, options = {})
      super(object_name, method_name, template_object, options)
    end

    def render
      options = @options.stringify_keys
      options['maxlength'] = options['size'] unless options.key?('maxlength')
      options['value'] = options.fetch('value') { value_before_type_cast(object) }
      options['label'] ||= @method_name.humanize
      add_default_name_and_id(options)
      tag('paper-textarea', options)
    end

  end

  class PaperAutocomplete < ActionView::Helpers::Tags::Base

    def initialize(object_name, method_name, template_object, options = {})
      super(object_name, method_name, template_object, options)
    end

    def render
      options = @options.stringify_keys
      options['maxlength'] = options['size'] unless options.key?('maxlength')
      options['value'] = options.fetch('value') { value_before_type_cast(object) }.name
      options['label'] ||= @method_name.humanize
      add_default_name_and_id(options)
      render_html(options) + "\n" + @template_object.javascript_tag(render_js(options))
    end

    def render_html(options)
      tag('paper-autocomplete', options)
    end

    def render_js(options)
      list = value(retrieve_object(false)).class.all.to_a.map{ |item| {text: item.name, value: item.id} }
      selected = list.select{ |item| item[:text] == options['value'] }.first
      "HTMLImports.whenReady(function(){" +
          "\n  var items = #{list.to_json};" +
          "\n  var autocomplete_field = document.querySelector('##{options['id']}');" +
          "\n  autocomplete_field.source = items;" +
          "\n  autocomplete_field.setOption(#{selected.to_json});" +
          "\n  autocomplete_field.enable();" +
          "\n});"
    end

  end

end