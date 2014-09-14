require_relative 'test_helper.rb'

class LinksTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::Test::Utils

  def app; App; end

  def test_visiting_index
    get('/')
    follow_redirect!
    assert_moved
    assert_equal('http://test.com/', last_request.url)
  end

  def test_visiting_admin
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body =~ /<title>Admin<\/title>/)
  end

  def test_creating_link
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    assert_equal(ENV['SLUG'].to_i, item.slug.length)
    assert_equal(File.join(ENV['SHORT'], item.slug), last_response.body)
    cleanup!
  end

  def test_visiting_link
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    get("/#{item.slug}")
    follow_redirect!
    assert_moved
    assert_equal('http://test.com/', last_request.url)
    item = App::Item.where(:url => 'http://test.com').first
    assert_equal(1, item.hits)
    cleanup!
  end

  def test_checking_link
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?(item.slug))
    cleanup!
  end

  def test_deleting_link
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    delete("/api?token=token&slug=#{item.slug}")
    assert_ok
    assert_equal('true', last_response.body)
    item = App::Item.where(:url => 'http://test.com').first
    assert(item.nil?)
    cleanup!
  end

  def test_creating_link_custom_slug
    get('/api?token=token&url=http://test.com&slug=test')
    assert_ok
    assert_equal(File.join(ENV['SHORT'], 'test'), last_response.body)
    item = App::Item.where(:slug => 'test').first
    assert(!item.nil?)
    cleanup!
  end

  def test_visiting_link_custom_slug
    get('/api?token=token&url=http://test.com&slug=test')
    assert_ok
    get('/test')
    follow_redirect!
    assert_moved
    assert_equal('http://test.com/', last_request.url)
    item = App::Item.where(:slug => 'test').first
    assert_equal(1, item.hits)
    cleanup!
  end

  def test_checking_link_custom_slug
    get('/api?token=token&url=http://test.com')
    assert_ok
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('test'))
    cleanup!
  end

  def test_deleting_link_custom_slug
    get('/api?token=token&url=http://test.com&slug=test')
    assert_ok
    delete('/api?token=token&slug=test')
    assert_ok
    assert_equal('true', last_response.body)
    item = App::Item.where(:slug => 'test').first
    assert(item.nil?)
    cleanup!
  end
end