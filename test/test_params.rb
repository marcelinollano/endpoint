require_relative 'test_helper.rb'

class TestParams < Minitest::Test
  include Rack::Test::Methods
  include Rack::Test::Utils

  def app; App; end

  def test_invalid_params_visiting_slug
    get('/test')           && assert_not_found
    get('/test/test')      && assert_not_found
    get('/test/test/test') && assert_not_found
  end

  def test_invalid_params_creating_link
    get('/api?token=token')                    && assert_bad_request
    get('/api?token=token&url=')               && assert_bad_request
    get('/api?token=token&url=http://')        && assert_bad_request
    get('/api?token=token&url=example.com')    && assert_bad_request
    get('/api?token=token&url=http://example') && assert_bad_request
  end

  def test_invalid_params_creating_media
    post('/api?token=token', 'media' => nil)
    assert_bad_request
  end

  def test_invalid_params_deleting
    delete('/api?token=token')              && assert_bad_request
    delete('/api?token=token&slug=')        && assert_bad_request
    delete('/api?token=token&slug=example') && assert_not_found
  end

  def test_invalid_params_visiting_admin
    create_links(100)
    authorize('user', 'pass')
    get('/admin?page=')                && assert_bad_request
    get('/admin?page=test')            && assert_bad_request
    get('/admin?order=')               && assert_bad_request
    get('/admin?order=test')           && assert_bad_request
    get('/admin?page=&order=')         && assert_bad_request
    get('/admin?page=test&order=test') && assert_bad_request
    cleanup!
  end
end