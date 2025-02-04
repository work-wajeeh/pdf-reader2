# coding: utf-8
# typed: strict
# frozen_string_literal: true

class Pdf::Reader2

  # Security handler for when we don't support the flavour of encryption
  # used in a Pdf.
  class UnimplementedSecurityHandler
    def self.supports?(encrypt)
      true
    end

    def decrypt(buf, ref)
      raise Pdf::Reader2::EncryptedPdfError, "Unsupported encryption style"
    end
  end
end
