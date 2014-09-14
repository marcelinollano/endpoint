require_relative 'test_helper.rb'

class ImagesTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::Test::Utils

  def app; App; end

  def test_creating_image
    post('/api?token=token', 'media' => image)
    assert_ok
    item = App::Item.first
    assert(!item.nil?)
    assert(File.file?(File.join('./public', item.url)))
    assert_equal(ENV['SLUG'].to_i, item.slug.length)
    assert_equal("<mediaurl>#{ENV['SHORT']}/#{item.slug}.#{item.type}</mediaurl>", last_response.body)
    cleanup!
  end

  def test_visiting_image
    post('/api?token=token', 'media' => image)
    assert_ok
    item = App::Item.first
    get("/#{item.slug}")
    assert_ok
    assert(last_response.body.include?(item.name))
    item = App::Item.first
    assert_equal(1, item.hits)
    cleanup!
  end

  def test_visiting_image_type
    post('/api?token=token', 'media' => image)
    assert_ok
    item = App::Item.first
    get("/#{item.slug}.#{item.type}")
    assert_found
    follow_redirect!
    assert_ok
    assert(last_request.url.include?(item.name))
    item = App::Item.first
    assert_equal(1, item.hits)
    cleanup!
  end

  def test_checking_image
    post('/api?token=token', 'media' => image)
    assert_ok
    item = App::Item.first
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?(item.slug))
    cleanup!
  end

  def test_deleting_image
    post('/api?token=token', 'media' => image)
    assert_ok
    item = App::Item.first
    delete("/api?token=token&slug=#{item.slug}")
    assert_ok
    assert_equal('true', last_response.body)
    assert(!File.file?(File.join('./public', item.url)))
    item = App::Item.first
    assert(item.nil?)
    cleanup!
  end

  def test_creating_image_custom_slug
    post('/api?token=token&slug=test', 'media' => image)
    assert_ok
    item = App::Item.where(:slug => 'test').first
    assert(!item.nil?)
    assert(File.file?(File.join('./public', item.url)))
    assert_equal("<mediaurl>#{ENV['SHORT']}/test.#{item.type}</mediaurl>", last_response.body)
    cleanup!
  end

  def test_visiting_image_custom_slug
    post('/api?token=token&slug=test', 'media' => image)
    assert_ok
    item = App::Item.where(:slug => 'test').first
    get('/test')
    assert_ok
    assert(last_response.body.include?(item.name))
    item = App::Item.where(:slug => 'test').first
    assert_equal(1, item.hits)
    cleanup!
  end

  def test_visiting_image_custom_slug_type
    post('/api?token=token&slug=test', 'media' => image)
    assert_ok
    item = App::Item.first
    get("/test.#{item.type}")
    assert_found
    follow_redirect!
    assert_ok
    assert(last_request.url.include?(item.name))
    item = App::Item.first
    assert_equal(1, item.hits)
    cleanup!
  end

  def test_checking_image_custom_slug
    post('/api?token=token&slug=test', 'media' => image)
    assert_ok
    item = App::Item.where(:slug => 'test').first
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('test'))
    cleanup!
  end

  def test_deleting_image_custom_slug
    post('/api?token=token&slug=test', 'media' => image)
    assert_ok
    item = App::Item.where(:slug => 'test').first
    delete('/api?token=token&slug=test')
    assert_ok
    assert_equal('true', last_response.body)
    assert(!File.file?(File.join('./public', item.url)))
    item = App::Item.where(:slug => 'test').first
    assert(item.nil?)
    cleanup!
  end
end