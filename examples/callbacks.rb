#!/usr/bin/env ruby
# coding: utf-8

# List all callbacks generated by each page
#
# WARNING: this will generate a *lot* of output, so you probably want to pipe
#          it through less or to a text file.

require 'rubygems'
require 'pdf/reader'

filename = File.expand_path(File.dirname(__FILE__)) + "/../spec/data/cairo-basic.pdf"

PDF::Reader2.open(filename) do |reader|
  reader.pages.each do |page|
    receiver = PDF::Reader2::RegisterReceiver.new
    page.walk(receiver)
    
    receiver.callbacks.each do |cb|
      puts cb
    end
  end
end
