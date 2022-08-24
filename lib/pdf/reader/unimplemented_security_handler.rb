# coding: utf-8
# typed: strict
# frozen_string_literal: true

class PDF2::Reader2

  # Security handler for when we don't support the flavour of encryption
  # used in a PDF.
  class UnimplementedSecurityHandler
    def self.supports?(encrypt)
      true
    end

    def decrypt(buf, ref)
      raise PDF2::Reader2::EncryptedPDFError, "Unsupported encryption style"
    end
  end
end
