require File.join(File.dirname(__FILE__), 'lib/menuer/build_menu.rb')

ActionView::Base.send(:include, Menuer::ActionView)
