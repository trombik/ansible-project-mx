#!/usr/bin/env ruby

require "yaml"
require "json"

file = ARGV.first
puts YAML.safe_load(File.read(file)).to_json
