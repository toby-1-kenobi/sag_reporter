# Make the will_paginate gem Materialize-friendly.
# https://gist.github.com/jkcorrea/050fd220999afb72210d

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options[:renderer] ||= MaterializeLinkRenderer
      super.try :html_safe
    end
 
    class MaterializeLinkRenderer < LinkRenderer
      protected
 
      def html_container(html)
        tag :ul, html, container_attributes
      end
 
      def page_number(page)
        tag :li,
            link(page, page, rel: rel_value(page)),
            class: (page == current_page ? 'active' : 'waves-effect')
      end
 
      def previous_or_next_page(page, text, classname)
        c = classname[0..3]
        tag :li,
            link(tag(:i, nil, class: "mdi-navigation-chevron-#{c == 'next' ? 'right' : 'left'}"), page || '#!'),
            class: [c, classname, ('disabled' unless page)].join(' ')
      end
 
      def gap
        text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
        %(<li><span class="gap">#{text}</span></li>)
      end
    end
  end
end