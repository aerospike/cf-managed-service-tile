#!/usr/bin/env ruby

require 'erb'

PRODUCT_VERSION = ARGV[0]
VERSION = ARGV[1]
ERB_TEMPLATE_FILE = ARGV[2]

simple_template = File.read("#{ERB_TEMPLATE_FILE}")

renderer = ERB.new(simple_template)
puts output = renderer.result()