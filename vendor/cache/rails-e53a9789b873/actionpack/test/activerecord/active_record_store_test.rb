require 'active_record_unit'
require 'digest/sha2'

class ActiveRecordStoreTest < ActionController::IntegrationTest
  DispatcherApp = ActionController::Dispatcher.new
  SessionApp = ActiveRecord::SessionStore.new(DispatcherApp,
                :key => '_session_id')
  SessionAppWithFixation = ActiveRecord::SessionStore.new(DispatcherApp,
                            :key => '_session_id', :cookie_only => false)

  class TestController < ActionController::Base
    def no_session_access
      head :ok
    end

    def set_session_value
      session[:foo] = params[:foo] || "bar"
      head :ok
    end

    def get_session_value
      render :text => "foo: #{session[:foo].inspect}"
    end

    def get_session_id
      render :text => "#{request.session_options[:id]}"
    end

    def call_reset_session
      session[:foo]
      reset_session
      session[:foo] = "baz"
      head :ok
    end

    def rescue_action(e) raise end
  end

  def setup
    ActiveRecord::SessionStore.session_class.create_table!
    ActiveRecord::SessionStore::Session.session_id_column = nil
    @integration_session = open_session(SessionApp)
  end

  def teardown
    ActiveRecord::SessionStore.session_class.drop_table!
  end

  %w{ session sql_bypass }.each do |class_name|
    define_method("test_setting_and_getting_session_value_with_#{class_name}_store") do
      with_store class_name do
        with_test_route_set do
          get '/set_session_value'
          assert_response :success
          assert cookies['_session_id']

          get '/get_session_value'
          assert_response :success
          assert_equal 'foo: "bar"', response.body

          get '/set_session_value', :foo => "baz"
          assert_response :success
          assert cookies['_session_id']

          get '/get_session_value'
          assert_response :success
          assert_equal 'foo: "baz"', response.body
        end
      end
    end
  end

  def test_getting_nil_session_value
    with_test_route_set do
      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
    end
  end

  def test_setting_session_value_after_session_reset
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id']
      session_id = cookies['_session_id']

      get '/call_reset_session'
      assert_response :success
      assert_not_equal [], headers['Set-Cookie']

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: "baz"', response.body

      get '/get_session_id'
      assert_response :success
      assert_not_equal session_id, response.body
    end
  end

  def test_getting_session_id
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id']
      session_id = cookies['_session_id']

      get '/get_session_id'
      assert_response :success
      assert_equal session_id, response.body
    end
  end

  def test_getting_session_value
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id']

      get '/get_session_value'
      assert_response :success
      assert_equal nil, headers['Set-Cookie'], "should not resend the cookie again if session_id cookie is already exists"
      session_id = cookies["_session_id"]

      get '/call_reset_session'
      assert_response :success
      assert_not_equal [], headers['Set-Cookie']

      cookies["_session_id"] = session_id # replace our new session_id with our old, pre-reset session_id

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body, "data for this session should have been obliterated from the database"
    end
  end

  def test_getting_from_nonexistent_session
    with_test_route_set do
      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: nil', response.body
      assert_nil cookies['_session_id'], "should only create session on write, not read"
    end
  end

  def test_prevents_session_fixation
    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id']

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: "bar"', response.body
      session_id = cookies['_session_id']
      assert session_id

      reset!

      get '/set_session_value', :_session_id => session_id, :foo => "baz"
      assert_response :success
      assert_equal nil, cookies['_session_id']

      get '/get_session_value', :_session_id => session_id
      assert_response :success
      assert_equal 'foo: nil', response.body
      assert_equal nil, cookies['_session_id']
    end
  end

  def test_allows_session_fixation
    @integration_session = open_session(SessionAppWithFixation)

    with_test_route_set do
      get '/set_session_value'
      assert_response :success
      assert cookies['_session_id']

      get '/get_session_value'
      assert_response :success
      assert_equal 'foo: "bar"', response.body
      session_id = cookies['_session_id']
      assert session_id

      reset!
      @integration_session = open_session(SessionAppWithFixation)

      get '/set_session_value', :_session_id => session_id, :foo => "baz"
      assert_response :success
      assert_equal session_id, cookies['_session_id']

      get '/get_session_value', :_session_id => session_id
      assert_response :success
      assert_equal 'foo: "baz"', response.body
      assert_equal session_id, cookies['_session_id']
    end
  end

  %w{ session sql_bypass }.each do |class_name|
    define_method :"test_sessions_are_indexed_by_a_hashed_session_id_mimicking_rack_for_#{class_name}" do
      with_store(class_name) do
        with_test_route_set do
          get '/set_session_value'
          assert_response :success
          public_session_id = cookies['_session_id']

          session = ActiveRecord::SessionStore::Session.last
          assert session
          assert_not_equal public_session_id, session.read_attribute(:session_id)

          expected_private_id = "2::#{Digest::SHA256.hexdigest(public_session_id)}"

          assert_equal expected_private_id, session.read_attribute(:session_id)
        end
      end
    end

    define_method :"test_unsecured_sessions_are_retrieved_and_migrated_for_#{class_name}" do
      with_store(class_name) do
        with_test_route_set do
          get '/set_session_value', :foo => 'baz'
          assert_response :success
          public_session_id = cookies['_session_id']

          session = ActiveRecord::SessionStore::Session.last
          session.data # otherwise we cannot save
          session.write_attribute(:session_id, public_session_id)
          session.save!

          get '/get_session_value'
          assert_response :success
          assert_equal 'foo: "baz"', response.body

          session = ActiveRecord::SessionStore::Session.last
          assert_not_equal public_session_id, session.read_attribute(:session_id)
        end
      end
    end

    # to avoid a different kind of timing attack
    define_method :"test_sessions_cannot_be_retrieved_by_their_private_session_id_for_#{class_name}" do
      with_store(class_name) do
        with_test_route_set do
          get '/set_session_value', :foo => 'baz'
          assert_response :success
          public_session_id = cookies['_session_id']

          session = ActiveRecord::SessionStore::Session.last
          private_session_id = session.read_attribute(:session_id)

          cookies['_session_id'] = private_session_id

          get '/get_session_value'
          assert_response :success
          assert_equal 'foo: nil', response.body
        end
      end
    end
  end

  def test_session_table_can_use_legacy_sessid_column
    with_store('session') do
      with_test_route_set do
        session_class = ActiveRecord::SessionStore.session_class
        session_class.drop_table!
        connection = session_class.connection
        connection.execute <<-SQL
            CREATE TABLE #{session_class.table_name} (
              id INTEGER PRIMARY KEY,
              #{connection.quote_column_name('sessid')} TEXT UNIQUE,
              #{connection.quote_column_name('data')} TEXT(255)
            )
        SQL
        get '/set_session_value'
        assert_response :success
        assert cookies['_session_id']

        get '/get_session_value'
        assert_response :success
        assert_equal 'foo: "bar"', response.body

        get '/set_session_value', :foo => "baz"
        assert_response :success
        assert cookies['_session_id']

        get '/get_session_value'
        assert_response :success
        assert_equal 'foo: "baz"', response.body
      end
    end
  end

  def test_session_can_be_secured
    with_store('session') do
      with_test_route_set do
        get '/set_session_value', :foo => 'baz'
        assert_response :success
        public_session_id = cookies['_session_id']

        session = ActiveRecord::SessionStore::Session.last
        private_session_id = session.read_attribute(:session_id)
        assert_not_equal public_session_id, private_session_id

        session.data # otherwise we cannot save
        session.write_attribute(:session_id, public_session_id)
        session.save!

        session.secure!
        session.reload
        assert_equal private_session_id, session.read_attribute(:session_id)

        get '/get_session_value'
        assert_response :success
        assert_equal 'foo: "baz"', response.body
      end
    end
  end

  def test_secure_is_idempotent
    with_store('session') do
      with_test_route_set do
        get '/set_session_value', :foo => 'baz'
        assert_response :success
        public_session_id = cookies['_session_id']

        session = ActiveRecord::SessionStore::Session.last
        private_session_id = session.read_attribute(:session_id)
        assert_not_equal public_session_id, private_session_id

        session.data # otherwise we cannot save
        session.write_attribute(:session_id, public_session_id)
        session.save!

        session.secure!
        session.secure!
        session.reload
        session.secure!
        assert_equal private_session_id, session.read_attribute(:session_id)
      end
    end
  end

  private
    def with_test_route_set
      with_routing do |set|
        set.draw do |map|
          map.with_options :controller => "active_record_store_test/test" do |c|
            c.connect "/:action"
          end
        end
        yield
      end
    end

    def with_store(class_name)
      begin
        session_class = ActiveRecord::SessionStore.session_class
        ActiveRecord::SessionStore.session_class = "ActiveRecord::SessionStore::#{class_name.camelize}".constantize
        yield
      rescue
        ActiveRecord::SessionStore.session_class = session_class
        raise
      end
    end

end
