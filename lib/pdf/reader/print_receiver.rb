# coding: utf-8
# typed: strict
# frozen_string_literal: true

class Pdf::Reader2
  # A simple receiver that prints all operaters and parameters in the content
  # stream of a single page.
  #
  class PrintReceiver

    attr_accessor :callbacks

    def initialize
      @callbacks = []
    end

    def respond_to?(meth)
      true
    end

    def method_missing(methodname, *args)
      puts "#{methodname} => #{args.inspect}"
    end
  end
end
