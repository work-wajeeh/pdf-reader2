# coding: utf-8
# typed: strict
# frozen_string_literal: true

# Copyright (C) 2010 James Healy (jimmy@deefa.com)

class Pdf::Reader2

  # An example receiver that just records all callbacks generated by parsing
  # a Pdf file.
  #
  # Useful for testing the contents of a file in an rspec/test-unit suite.
  #
  # Usage:
  #
  #     Pdf::Reader2.open("somefile.pdf") do |reader|
  #       receiver = Pdf::Reader2::RegisterReceiver.new
  #       reader.page(1).walk(receiver)
  #       callback = receiver.first_occurance_of(:show_text)
  #       callback[:args].first.should == "Hellow World"
  #     end
  #
  class RegisterReceiver

    attr_accessor :callbacks

    def initialize
      @callbacks = []
    end

    def respond_to?(meth)
      true
    end

    def method_missing(methodname, *args)
      callbacks << {:name => methodname.to_sym, :args => args}
    end

    # count the number of times a callback fired
    def count(methodname)
      callbacks.count { |cb| cb[:name] == methodname}
    end

    # return the details for every time the specified callback was fired
    def all(methodname)
      callbacks.select { |cb| cb[:name] == methodname }
    end

    def all_args(methodname)
      all(methodname).map { |cb| cb[:args] }
    end

    # return the details for the first time the specified callback was fired
    def first_occurance_of(methodname)
      callbacks.find { |cb| cb[:name] == methodname }
    end

    # return the details for the final time the specified callback was fired
    def final_occurance_of(methodname)
      all(methodname).last
    end

    # return the first occurance of a particular series of callbacks
    def series(*methods)
      return nil if methods.empty?

      indexes = (0..(callbacks.size-1))
      method_indexes = (0..(methods.size-1))

      indexes.each do |idx|
        count = methods.size
        method_indexes.each do |midx|
          count -= 1 if callbacks[idx+midx] && callbacks[idx+midx][:name] == methods[midx]
        end
        if count == 0
          return callbacks[idx, methods.size]
        end
      end
      nil
    end
  end
end
