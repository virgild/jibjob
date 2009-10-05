# coding: utf-8
if RUBY_VERSION.split('.')[1].to_i > 8
  Encoding.default_external = 'UTF-8'
end

require 'rubygems'
require 'rack'
require 'app'

run JibJob::App
