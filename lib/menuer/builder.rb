module Menuer

# This class is a helper to implement tabbed menues.
# The idea behind the class is to put the logic of the menu in only one place, probably a helper,
# and then easily render it in the views.
# Allows customization of the HTML rendered, both in unselected and selected tab conditions.
# It doesn't renders the tabs, it's only responsability is to render de links with
# the desired selection state and attributes.
# Full customization is supported for HTML attributes and selection conditions.
class Builder
  include Enumerable

  # Default tab link renderer.
  cattr_accessor :default_renderer
  @@default_renderer = LinkToRenderer

  # +template+: the rendering module used, normally, since +MenuCreator+ is called from a view, +self+ is passed.
  # +default_selected_options+: default HTML options that will be merged do +default_html_options+ in the link when it's selected
  # +default_html_options+: default HTML options for the link.
  # +renderer+: link renderer object. If not passed <tt>MenuCreator::default_renderer</tt> will be used
  def initialize(template, default_selected_options, default_html_options = {}, renderer = default_renderer.new(template))
    @template, @html_options, @selected_options, @renderer = template, default_html_options, default_selected_options, renderer
    @tabs = []
  end

  # Adds a new tab to the menu.
  #
  # +name+: text that will be rendered for the tab.
  # +options+: url options for the link, can take any form +link_to+ accepts.
  # +page_selector+: set of pages where the tab is rendered as selected. If nil,
  # a new empty selector will be created.
  # This methos is aliased as +add_option+ and +add_item+.
  def add_tab(name, options, page_selector = nil)
    returning Tab.new(@template, @renderer, name, options, page_selector) do |tab|
      tab.html_options = @html_options
      tab.selected_options = @selected_options
      @tabs << tab
    end
  end

  # Creates a new tab and then calls Tab#selected_on_pages passing +pages+.
  # If +pages+ is empty, +options+ is used as the only selected page.
  # This methos is aliased as +add_option_with_selected_options+ and +add_item_with_selected_options+.
  def add_tab_with_selected_options(name, options, *selected_options)
    selected_options = [options] if selected_options.empty?
    add_tab(name, options, PageSelector.create_selected_on_options(@template, *selected_options))
  end

  # Creates a new tab and then calls Tab#selected_on_match passing +controller_regex+ and +action_regex+
  # This methos is aliased as +add_option_with_selected_match+ and +add_item_with_selected_match+.
  def add_tab_with_selected_match(name, options, controller_regex, action_regex = nil)
    add_tab(name, options, PageSelector.create_selected_on_matching_regex(@template, controller_regex, action_regex))
  end

  # Creates a new tab and then calls Tab#selected_on passing +block+.
  # This methos is aliased as +add_option_with_selected_block+ and +add_item_with_selected_block+.
  def add_tab_with_selected_block(name, options, &block)
    add_tab(name, options, PageSelector.create_selected_on(@template, &block))
  end

  # Iterator through visible tabs. It yields its +block+ passing the +Tab+ as argument.
  # see: Tab#visible? and Tab#visible_on
  def each
    each_all do |tab|
      yield(tab) if tab.visible?
    end
  end

  # Iterator through all tabs, visible and hidden ones.
  # It yields its +block+ passing the +Tab+ as argument.
  # see: Tab#visible? and Tab#visible_on
  def each_all
    @tabs.each {|tab| yield(tab)}
  end

  private

  def self.setup_aliases
    targets = public_instance_methods(false).grep(/add_tab/)
    targets.each do |method| 
      alias_method(method.sub('tab', 'item'), method)
      alias_method(method.sub('tab', 'option'), method)
    end
  end
  private_class_method :setup_aliases
  setup_aliases

end # class Builder

end # module Menuer
