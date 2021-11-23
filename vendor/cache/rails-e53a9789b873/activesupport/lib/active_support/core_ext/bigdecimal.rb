require 'bigdecimal'
require 'active_support/core_ext/bigdecimal/conversions'
require 'active_support/core_ext/bigdecimal/new'

class BigDecimal#:nodoc:
  include ActiveSupport::CoreExtensions::BigDecimal::Conversions
  include ActiveSupport::CoreExtensions::BigDecimal::New unless BigDecimal.respond_to?(:new)
end
