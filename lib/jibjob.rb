# coding: utf-8

require 'rubygems'

gems = [
  ['extlib', '>= 0.9.13'],
  ['sinatra', '>= 0.10.1'],
  ['nakajima-rack-flash', '>= 0.1.0'],
  ['haml', '>= 2.2.4'],
  ['bcrypt-ruby', '>= 2.1.2'],
  ['uuidtools', '>= 2.0.0'],
  ['resumetools', '>= 0.2.6'],
  ['dm-core', '>= 0.10.0'],
  ['dm-timestamps', '>= 0.10.0'],
  ['dm-aggregates', '>= 0.10.0'],
  ['dm-constraints', '>= 0.10.0'],
  ['dm-is-viewable', '>= 0.10.0'],
  ['dm-validations', '>= 0.10.0'],
  ['sanitize', '>= 1.0.8']
]

gems.each do |name, version|
  if File.directory?(File.expand_path(File.dirname(__FILE__) + "/../vendor/#{name}"))
    $:.unshift "#{File.dirname(__FILE__)}/../vendor/#{name}/lib"
    require name
  else
    if version
      gem name, version
    else
      gem name
    end
  end
end

require 'extlib'
require 'iconv'
require 'sinatra/base'
require 'rack/flash'
require 'haml'
require 'sass'
require 'bcrypt'
require 'uuidtools'
require 'resumetools'
require 'net/http'
require 'cgi'
require 'sanitize'

require 'dm-core'
require 'dm-timestamps'
require 'dm-aggregates'
require 'dm-constraints'
require 'dm-is-viewable'
require 'dm-validations'


dir = Pathname(__FILE__).dirname.expand_path / 'jibjob'

require dir / 'app'
