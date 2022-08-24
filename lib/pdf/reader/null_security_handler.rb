# coding: utf-8
# typed: strict
# frozen_string_literal: true

class Pdf::Reader2

  # A null object security handler. Used when a Pdf is unencrypted.
  class NullSecurityHandler

    def decrypt(buf, _ref)
      buf
    end
  end
end
