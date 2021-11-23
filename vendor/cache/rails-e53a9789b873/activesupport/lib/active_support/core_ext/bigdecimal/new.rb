module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module BigDecimal #:nodoc:
      module New

        def self.included(klass)
          def klass.new(*args)
            Kernel.BigDecimal(*args)
          end
        end

      end
    end
  end
end
