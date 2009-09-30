# coding: utf-8

module JibJob
  module Helpers
    module RenderingHelper
      def show(view, options={})
        haml(view, options)
      end
      
      def partial(template, locals={})
        haml("_#{template}".to_sym, :locals => locals, :layout => false)
      end
    end
  end
end