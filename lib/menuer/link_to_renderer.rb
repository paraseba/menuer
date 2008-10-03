module Menuer

# This class works in conjuntion with +MenuCreator+ to render menues.
# Its responsability is to render links.
class LinkToRenderer
  # +template+: the rendering module used, normally, since +MenuCreator+ is called from a view, +self+ is passed.
  def initialize(template)
    @template = template
  end

  # Render the target link
  # In this implementation we just call +link_to+ on the template
  #
  # +name+: text that will be rendered for the tab.
  # +options+: url options for the link, can take any form +link_to+ accepts.
  # +html_options+: HTML options for the link.
  def render(name, options = {}, html_options = {})
    @template.link_to(name, options, html_options)
  end
end

end # module Menuer
