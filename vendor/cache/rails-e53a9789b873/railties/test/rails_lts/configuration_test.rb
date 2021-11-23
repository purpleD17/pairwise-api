require 'abstract_unit'
require 'railslts'

class RailsLtsConfigurationTest < ActiveSupport::TestCase

  test 'compatible defaults' do
    configuration = RailsLts::Configuration.new(:default => :compatible)
    assert_equal false, configuration.disable_json_parsing
    assert_equal false, configuration.disable_xml_parsing
    assert_equal false, configuration.escape_html_entities_in_json
    assert_equal false, configuration.strict_unambiguous_table_names
    assert_equal false, configuration.allow_strings_for_polymorphic_paths
  end

  test 'hardened defaults' do
    configuration = RailsLts::Configuration.new(:default => :hardened)
    assert_equal true, configuration.disable_json_parsing
    assert_equal true, configuration.disable_xml_parsing
    assert_equal true, configuration.escape_html_entities_in_json
    assert_equal true, configuration.strict_unambiguous_table_names
    assert_equal false, configuration.allow_strings_for_polymorphic_paths
  end

  test 'disabling one option' do
    configuration = RailsLts::Configuration.new(:default => :hardened, :allow_strings_for_polymorphic_paths => true)
    assert_equal true, configuration.allow_strings_for_polymorphic_paths
  end

end
