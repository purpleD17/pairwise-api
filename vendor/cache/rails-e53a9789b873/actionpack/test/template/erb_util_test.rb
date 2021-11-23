require 'abstract_unit'

class ErbUtilTest < Test::Unit::TestCase
  include ERB::Util

  ERB::Util::HTML_ESCAPE.each do |given, expected|
    define_method "test_html_escape_#{expected.gsub /\W/, ''}" do
      assert_equal expected, html_escape(given)
    end

    unless given == '"' || given == "'"
      define_method "test_json_escape_#{expected.gsub /\W/, ''}" do
        assert_equal ERB::Util::JSON_ESCAPE[given], json_escape(given)
      end
    end
  end

  HTML_ESCAPE_TEST_CASES = [
    ['<br>', '&lt;br&gt;'],
    ['a & b', 'a &amp; b'],
    ['"quoted" string', '&quot;quoted&quot; string'],
    ["'quoted' string", '&#39;quoted&#39; string'],
    [
      '<script type="application/javascript">alert("You are \'pwned\'!")</script>',
      '&lt;script type=&quot;application/javascript&quot;&gt;alert(&quot;You are &#39;pwned&#39;!&quot;)&lt;/script&gt;'
    ]
  ]

  JSON_ESCAPE_TEST_CASES = [
    ['1', '1'],
    ['null', 'null'],
    ['&', '\u0026'],
    ['</script>', '\u003C/script\u003E'],
    ['[</script>]', '[\u003C/script\u003E]'],
    [%(d\u2028h\u2029h), 'd\u2028h\u2029h']
  ]

  def test_html_escape
    HTML_ESCAPE_TEST_CASES.each do |(raw, expected)|
      assert_equal expected, html_escape(raw)
    end
  end

  def test_json_escape
    JSON_ESCAPE_TEST_CASES.each do |(raw, expected)|
      assert_equal expected, json_escape(raw)
    end
  end

  def test_html_escape_is_html_safe
    escaped = h("<p>")
    assert_equal "&lt;p&gt;", escaped
    assert escaped.html_safe?
  end

  def test_html_escape_passes_html_escpe_unmodified
    escaped = h("<p>".html_safe)
    assert_equal "<p>", escaped
    assert escaped.html_safe?
  end

  def test_rest_in_ascii
    (0..127).to_a.map(&:chr).each do |chr|
      next if %w(& " < > ').include?(chr)
      assert_equal chr, html_escape(chr)
    end
  end
end
