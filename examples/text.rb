#!/usr/bin/env ruby
# coding: utf-8

# Extract all text from a single Pdf

require 'rubygems'
require 'pdf/reader'

filename = File.expand_path(File.dirname(__FILE__)) + "/../spec/data/cairo-unicode.pdf"

Pdf2::Reader2.open(filename) do |reader|
  reader.pages.each do |page|
    puts page.text
  end
end
