module Menuer

# This class works in conjuntion with +MenuCreator+ to render menues.
# Its responsability is to render link_to_fuctions.
class LinkToFunctionRenderer
  # +template+: the rendering module used, normally, since +MenuCreator+ is called from a view, +self+ is passed.
  def initialize(template)
    @template = template
  end

  # Render the target link
  # In this implementation we just call +link_to_function+ on the template
  #
  # +name+: text that will be rendered for the tab.
  # +function+:  js fuction for the link, can take any form +link_to_function+ accepts.
  # +html_options+: HTML options for the link.
  def render(name, function='', html_options = {})
    @template.link_to_function(name, function, html_options)
  end
end

end # module Menuer
