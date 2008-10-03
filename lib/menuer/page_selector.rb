module Menuer

# Defines set of conditions to indicate if the _current_ page is selected.
# Here selected has no particular sense, so, the class defines just a set of pages.
class PageSelector

  # +template+: the rendering module used, normally, since +MenuCreator+ is called from a view, +self+ is passed.
  def initialize(template)
    @template = template
    @conditions = []
  end

  class << self
    # Creates a new PageSelector instance, calling on_matching_regex after creation.
    # See: on_matching_regex
    def create_selected_on_matching_regex(template, controller_regex, action_regex = nil)
      returning PageSelector.new(template) do |s| 
        s.on_matching_regex(controller_regex, action_regex)
      end
    end

    # Creates a new PageSelector instance, calling on_options after creation.
    # See: on_options
    def create_selected_on_options(template, *options)
      returning PageSelector.new(template) do |s|
        s.on_options(*options)
      end
    end

    # Creates a new PageSelector instance, calling on after creation.
    # See: on
    def create_selected_on(template, &block)
      returning PageSelector.new(template) do
        |s| s.on(&block)
      end
    end
  end

  # Add a condition to decide when the selector is in _selected_ condition. This condition will be
  # ored with all other available conditions
  # +controller_regex+: regular expression (or string used to build one) that will be matched against
  # current controller path, to decide if the link shold be displayed as selected.
  # +action_regex+: regular expression (or string used to build one) that will be matched against
  # current action, to decide if the link shold be displayed as selected. If nil is passed, a match all
  # expression is used. +action_regex+ and +controller_regex+ must both match for the tab to be considered
  # as selected.
  # Sample: selector.on_matching_regex(/companies\/show/)
  def on_matching_regex(controller_regex, action_regex = nil)
    @conditions << construct_condition_for_regex(controller_regex, action_regex)
  end

  # Add a condition to decide when the selector is in _selected_ condition. This condition will be
  # ored with all other available conditions
  # +options+: one or more sets of options in +url_for+ format. The selector will be selected if the current
  # page URL can be generated from any of this options.
  # Sample: selector.on_options(companies_path, {:controller => 'public', :action => 'index'})
  def on_options(*options)
    @conditions << construct_condition_for_options(options)
  end

  # Add a condition to decide when the selector is in _selected_ condition. This condition will be
  # ored with all other available conditions
  # +block+: block yielded at rendering time to decide if selector is currently selected.
  # Sample: selector.selected_on {@user.admin?}
  def on(&block)
    @conditions << block
  end

  # Returns weather the current page is selected or not.
  # see: on, on_options, on_matching_regex
  def current_page_selected?(current_controller_path, current_action)
    @conditions.detect {|cond| call_client_block(current_controller_path, current_action, &cond)}
  end

  private

  def call_client_block(current_controller_path, current_action)
    yield(current_controller_path, current_action)
  end

  def construct_condition_for_regex(controller_regex, action_regex)
    controller_regex, action_regex = sanitize_regex(controller_regex, action_regex)
    lambda {|cont_path, action| (cont_path =~ controller_regex) && (action =~ action_regex)}
  end

  def construct_condition_for_options(options)
    lambda {is_selected_by_options?(options)}
  end

  def sanitize_regex(controller_regex, action_regex)
    raise ArgumentError.new('Regular expressions for at least one of controller path and action name must be provided') unless controller_regex || action_regex
    controller_regex ||= MATCH_ALL
    action_regex ||= MATCH_ALL
    controller_regex = Regexp.new(controller_regex.to_s) unless controller_regex.is_a?(Regexp)
    action_regex = Regexp.new(action_regex.to_s) unless action_regex.is_a?(Regexp)
    [controller_regex, action_regex]
  end

  def is_selected_by_options?(options)
    options.detect do |page_opts|
      options_map = page_opts.is_a?(Proc) ? page_opts.call : page_opts
      @template.current_page?(options_map)
    end
  end

  MATCH_ALL = /.*/
end # class PageSelector

end # module Menuer
