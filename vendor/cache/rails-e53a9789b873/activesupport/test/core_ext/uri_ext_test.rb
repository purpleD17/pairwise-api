require 'abstract_unit'
require 'uri'

class URIExtTest < Test::Unit::TestCase
  def test_uri_decode_handle_multibyte
    str = "\xE6\x97\xA5\xE6\x9C\xAC\xE8\xAA\x9E" # Ni-ho-nn-go in UTF-8, means Japanese.
    str.force_encoding(Encoding::UTF_8) if str.respond_to?(:force_encoding)

    if RUBY_VERSION < '2.6'
      assert_equal str, URI.unescape(URI.escape(str))
      assert_equal str, URI.decode(URI.escape(str))
    else
      Kernel.silence_warnings do # Avoid URI deprecation warnings
        escaped_str = URI.escape(str).freeze

        assert_equal str, URI.unescape(escaped_str)
        assert_equal str, URI.decode(escaped_str)
        assert_equal str, RailsLts::Support::URI.unescape_uri(escaped_str)
      end
    end
  end

  if RUBY_VERSION >= '2.6'
    # Tests inspired by Rails 4.2 (actionpack/test/journey/router/utils_test.rb)

    def test_railslts_support_uri_escape_unsafe_characters
      assert_equal "a/b%20c+d%25", RailsLts::Support::URI.escape_unsafe_characters("a/b c+d%", /[^\/a-z0-9+]/)
      assert_equal "a%2Fb%20c+d%25", RailsLts::Support::URI.escape_unsafe_characters("a/b c+d%", /[^a-z0-9+]/)
      assert_equal "a/b%20c+d%25?e", RailsLts::Support::URI.escape_unsafe_characters("a/b c+d%?e", /[^\/a-z0-9+?]/)
    end

    def test_railslts_support_uri_unescape_safe_characters
      assert_equal "a/b c+d", RailsLts::Support::URI.unescape_uri("a%2Fb%20c+d")
      assert_equal "Šašinková", RailsLts::Support::URI.unescape_uri("%C5%A0a%C5%A1inkov%C3%A1".force_encoding(Encoding::US_ASCII))
    end
  end

end
