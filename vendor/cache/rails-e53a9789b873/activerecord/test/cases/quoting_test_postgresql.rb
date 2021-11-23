require "cases/helper"
require 'models/bird'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      class QuotingTest < ActiveRecord::TestCase
        def setup
          @conn = ActiveRecord::Base.connection
        end

        def test_quote_true
          c = PostgreSQLColumn.new(nil, 1, 'boolean')
          assert_equal "'t'", @conn.quote(true, nil)
          assert_equal "'t'", @conn.quote(true, c)
        end

        def test_quote_false
          c = PostgreSQLColumn.new(nil, 1, 'boolean')
          assert_equal "'f'", @conn.quote(false, nil)
          assert_equal "'f'", @conn.quote(false, c)
        end

        def test_quote_range
          # There is no range support on 2.3's PG adapter, but we still want to
          # make sure that SQL injection is not possible since it was an issue
          # on Rails 4.x.
          # https://groups.google.com/d/msg/rubyonrails-security/wDxePLJGZdI/WP7EasCJTA4J
          #
          # Note that we can not test this using Connection#quote because
          # ActiveRecord expands ranges into two bind variables that are
          # quoted individually.
          range = "1,2]'; SELECT * FROM users; --".."a"
          sql = Bird.scoped(:conditions => { :name => range }).construct_finder_sql({})
          expected_sql = %{SELECT * FROM "birds" WHERE ("birds"."name" BETWEEN '1,2]''; SELECT * FROM users; --' AND 'a') }
          assert_equal expected_sql, sql
        end

        def test_quote_bit_string
          c = PostgreSQLColumn.new(nil, 1, 'bit')
          assert_equal nil, @conn.quote("'); SELECT * FORM users; /*\n01\n*/--", c)
        end
      end
    end
  end
end
