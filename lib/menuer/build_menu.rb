module Menuer
  module ActionView
    def build_menu(*args)
      Menuer::Builder.new(*args)
    end
  end
end
