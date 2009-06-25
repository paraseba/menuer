module Menuer

  # Represents each of the menu options.
  # This is the class where most of the option properties are set.
  # Supports hiding the tab, changing HTML properties, and several mechanisms to
  # decide if the tab should be rendered as currently selected or not.
  class Tab
    # +template+: the rendering module used, normally, since +MenuCreator+ is called from a view, +self+ is passed.
    # +renderer+: link renderer object.
    # +name+: the name of the tab, text that will be shown to the user in the link. +name+ could be a +String+ or a +Proc+.
    # In the later case, it will be called at rendering time to get the name to show.
    # +options+: url options for the link, can take any form +link_to+ accepts. +options+ could be also a +Proc+, in
    # which case, it will be called at rendering time to get the options.
    def initialize(template, renderer, name, options, page_selector = nil)
      @template, @renderer = template, renderer
      @name, @options = name, options
      @html_options = Hash.new
      @selected_options = Hash.new
      @page_selector = page_selector || PageSelector.new(@template)
    end

    # +name+ can be read.
    attr_reader   :name
    # +renderer+ can be accessed and modified.
    attr_accessor :renderer
    # +options+, +html_options+, and +selected_options+ can be accessed and modified after tab creation.
    # If not modified, menu defaults will be used.
    attr_accessor :options, :html_options, :selected_options

    # +page_selector+ can be accessed to set page selection for the tab.
    attr_reader :page_selector

    # Declare that this tab is not allways visible. At rendering time, +block+ will be yielded
    # to decide if the tab must be displayed or not.
    def visible_on(&block)
      @visible_on_block = block
    end

    # Returns weather this tab should be renderer or not.
    # see: visible_on
    def visible?
      @visible_on_block.nil? || call_client_block(&@visible_on_block)
    end

    # Returns weather this tab should be renderer as selected or not.
    # see: selected_on, selected_on_pages, selected_on_match
    def selected?
      @page_selector.current_page_selected?(*controller_and_action)
    end

    # Do the actual rendering of the tab's link.
    def render
      if renderer.respond_to?(:render_tab)
        renderer.render_tab(tab, get_or_call(name), get_or_call(options), tab_render_options)
      else
        renderer.render(get_or_call(name), get_or_call(options), tab_render_options)
      end
    end

    private

    def call_client_block
      yield(self, *controller_and_action)
    end

    def get_or_call(object)
      object.is_a?(Proc) ? call_client_block(&object) : object
    end

    def controller_and_action
      path = @template.instance_variable_get(:@current_controller_path)
      action = @template.instance_variable_get(:@current_action)
      [path, action]
    end

    def tab_render_options
      selected? ? html_options.merge(selected_options) : html_options
    end
  end # class Tab

end # module Menuer
