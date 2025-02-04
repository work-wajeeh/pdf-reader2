# coding: utf-8
# typed: strict
# frozen_string_literal: true

require 'digest/md5'

class Pdf::Reader2

  # Decrypts data using the AESV2 algorithim defined in the Pdf spec. Requires
  # a decryption key, which is usually generated by Pdf::Reader2::StandardKeyBuilder
  #
  class AesV2SecurityHandler

    def initialize(key)
      @encrypt_key = key
    end

    ##7.6.2 General Encryption Algorithm
    #
    # Algorithm 1: Encryption of data using the AES-128-CBC algorithm
    #
    # version == 4 and CFM == AESV2
    #
    # buf - a string to decrypt
    # ref - a Pdf::Reader2::Reference for the object to decrypt
    #
    def decrypt( buf, ref )
      objKey = @encrypt_key.dup
      (0..2).each { |e| objKey << (ref.id >> e*8 & 0xFF ) }
      (0..1).each { |e| objKey << (ref.gen >> e*8 & 0xFF ) }
      objKey << 'sAlT'  # Algorithm 1, b)
      length = objKey.length < 16 ? objKey.length : 16
      cipher = OpenSSL::Cipher.new("AES-#{length << 3}-CBC")
      cipher.decrypt
      cipher.key = Digest::MD5.digest(objKey)[0,length]
      cipher.iv = buf[0..15]
      cipher.update(buf[16..-1]) + cipher.final
    end

  end
end
