#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"

file = ARGV.first
puts YAML.safe_load(File.read(file)).to_json
