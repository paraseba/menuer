module Menuer
  module ActionView
    def build_menu(*args, &block)
      Menuer::Builder.new(*args, &block)
    end
  end
end
