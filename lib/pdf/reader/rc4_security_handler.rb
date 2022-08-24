# coding: utf-8
# typed: strict
# frozen_string_literal: true

require 'digest/md5'
require 'rc4'

class PDF2::Reader2

  # Decrypts data using the RC4 algorithim defined in the PDF spec. Requires
  # a decryption key, which is usually generated by PDF2::Reader2::StandardKeyBuilder
  #
  class Rc4SecurityHandler

    def initialize(key)
      @encrypt_key = key
    end

    ##7.6.2 General Encryption Algorithm
    #
    # Algorithm 1: Encryption of data using the RC4 algorithm
    #
    # version <=3 or (version == 4 and CFM == V2)
    #
    # buf - a string to decrypt
    # ref - a PDF2::Reader2::Reference for the object to decrypt
    #
    def decrypt( buf, ref )
      objKey = @encrypt_key.dup
      (0..2).each { |e| objKey << (ref.id >> e*8 & 0xFF ) }
      (0..1).each { |e| objKey << (ref.gen >> e*8 & 0xFF ) }
      length = objKey.length < 16 ? objKey.length : 16
      rc4 = RC4.new( Digest::MD5.digest(objKey)[0,length] )
      rc4.decrypt(buf)
    end

  end
end
