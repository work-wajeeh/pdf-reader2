#!/usr/bin/env ruby
# coding: utf-8

# Determine the Pdf version of a file

require 'rubygems'
require 'pdf/reader'

filename = File.expand_path(File.dirname(__FILE__)) + "/../spec/data/cairo-basic.pdf"

Pdf::Reader2.open(filename) do |reader|
  puts reader.pdf_version
end
