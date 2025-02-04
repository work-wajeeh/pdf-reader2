# coding: utf-8
# typed: strict
# frozen_string_literal: true

require 'digest'
require 'openssl'

class Pdf::Reader2

  # Decrypts data using the AESV3 algorithim defined in the Pdf 1.7, Extension Level 3 spec.
  # Requires a decryption key, which is usually generated by Pdf::Reader2::KeyBuilderV5
  #
  class AesV3SecurityHandler

    def initialize(key)
      @encrypt_key = key
      @cipher = "AES-256-CBC"
    end

    ##7.6.2 General Encryption Algorithm
    #
    # Algorithm 1: Encryption of data using the RC4 or AES algorithms
    #
    # used to decrypt RC4/AES encrypted Pdf streams (buf)
    #
    # buf - a string to decrypt
    # ref - a Pdf::Reader2::Reference for the object to decrypt
    #
    def decrypt( buf, ref )
      cipher = OpenSSL::Cipher.new(@cipher)
      cipher.decrypt
      cipher.key = @encrypt_key.dup
      cipher.iv = buf[0..15]
      cipher.update(buf[16..-1]) + cipher.final
    end

  end
end
