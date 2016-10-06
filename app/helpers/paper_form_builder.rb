require 'json'

class PaperFormBuilder < ActionView::Helpers::FormBuilder

  def paper_text_field(method, options = {})
    PaperTextField.new(@object_name, method, @template, options).render
  end

  def paper_autocomplete(method, options = {})
    autocomplete = PaperAutocomplete.new(@object_name, method, @template, options).render
  end
  def paper_autocomplete_js(method, options = {})
    autocomplete = PaperAutocomplete.new(@object_name, method, @template, options).renderjs
  end

  def paper_textarea(method, options = {})
    PaperTextArea.new(@object_name, method, @template, options).render
  end

  def paper_checkbox(method, options = {})
    PaperCheckbox.new(@object_name, method, @template, options).render
  end

  def paper_radio_group(method, options = {})
    PaperRadioGroup.new(@object_name, method, @template, options).render
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

  class PaperCheckbox < ActionView::Helpers::Tags::CheckBox

    def initialize(object_name, method_name, template_object, options = {})
      super(object_name, method_name, template_object, 1, 0, options)
    end

    def render
      options = @options.stringify_keys
      options['value']    = @checked_value
      options['checked'] = 'checked' if input_checked?(object, options)
      label = options.fetch('label', @method_name.humanize)
      options.delete('label')

      if options['multiple']
        add_default_name_and_id_for_value(@checked_value, options)
        options.delete('multiple')
      else
        add_default_name_and_id(options)
      end

      include_hidden = options.delete('include_hidden') { true }
      checkbox = content_tag('paper-checkbox', label, options)

      if include_hidden
        hidden = hidden_field_for_checkbox(options)
        hidden + checkbox
      else
        checkbox
      end
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

  class PaperRadioGroup < ActionView::Helpers::Tags::Base

    def initialize(object_name, method_name, template_object, options = {})
      super(object_name, method_name, template_object, options)
    end

    def render
      options = @options.stringify_keys
      options['selected'] = options.fetch('selected') { value_before_type_cast(object) }
      options['label'] ||= @method_name.humanize
      label = options.delete('label')
      # vertical alignment of radio buttons using iron-flex-layout
      options['class'] ||= ''
      options['class'] += ' layout vertical start'
      options['class'].strip!
      # set the selected attribute to be the value, not the name
      options['attr-for-selected'] = 'value'
      add_default_name_and_id(options)
      name = options.delete('name')
      # assumption is that all valid values are stored as an enum on the model
      # that can be accessed with the plural of the method name
      collection = retrieve_object(false).class.send(@method_name.pluralize).keys
      radios = "\n<label>#{label}</label>"
      collection.each do |item|
        radios += content_tag('paper-radio-button', item.humanize, name: name, value: item) + "\n"
      end
      # paper-radio-group has non-boolean 'selected' attribute
      BOOLEAN_ATTRIBUTES.delete('selected')
      content_tag('paper-radio-group', radios.html_safe, options)
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
      tag('paper-autocomplete', options)
    end

    def renderjs()
      options = @options.stringify_keys
      options['value'] = options.fetch('value') { value_before_type_cast(object) }.name
      add_default_name_and_id(options)
      list = value(retrieve_object(false)).class.all.to_a.map{ |item| {text: item.name, value: item.id} }
      selected = list.select{ |item| item[:text] == options['value'] }.first
      js = "window.addEventListener('WebComponentsReady', function(){" +
          "\n  var items = #{list.to_json};" +
          "\n  var autocomplete_field = document.querySelector('##{options['id']}');" +
          "\n  autocomplete_field.source = items;" +
          "\n  autocomplete_field.setOption(#{selected.to_json});" +
          "\n  autocomplete_field.enable();" +
          "\n});"
      @template_object.javascript_tag(js)
    end

  end

end