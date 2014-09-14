module Rack::Test::Methods
  def assert_ok
    assert_equal(200, last_response.status)
  end

  def assert_moved
    assert_equal(301, last_response.status)
  end

  def assert_found
    assert_equal(302, last_response.status)
  end

  def assert_bad_request
    assert_equal('Bad Request', last_response.body)
    assert_equal(400, last_response.status)
  end

  def assert_unauthorized
    assert_equal('Unauthorized', last_response.body)
    assert_equal(401, last_response.status)
  end

  def assert_not_found
    assert_equal('Not Found', last_response.body)
    assert_equal(404, last_response.status)
  end
end