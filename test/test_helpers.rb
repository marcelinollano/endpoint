require_relative 'test_helper.rb'

class TestHelpers < Minitest::Test
  include Rack::Test::Methods
  include Rack::Test::Utils

  def app; App; end

  def test_created_just_now
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - 60)
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('Just now'))
    cleanup!
  end

  def test_created_minutes_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (2 * 60))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('2 minutes ago'))
    cleanup!
  end

  def test_created_hour_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - 3600)
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('1 hour ago'))
    cleanup!
  end

  def test_created_hours_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (2 * 3600))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('2 hours ago'))
    cleanup!  end

  def test_created_day_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - 86400)
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('1 day ago'))
    cleanup!
  end

  def test_created_days_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (3 * 86400))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('3 days ago'))
    cleanup!
  end

  def test_created_month_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (30 * 86400))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('1 month ago'))
    cleanup!
  end

  def test_created_months_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (60 * 86400))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('2 months ago'))
    cleanup!
  end

  def test_created_year_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (365 * 86400))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('1 year ago'))
    cleanup!
  end

  def test_created_years_ago
    get('/api?token=token&url=http://test.com')
    assert_ok
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    item.update(:created_at => Time.now - (3 * 365 * 86400))
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('3 years ago'))
    cleanup!
  end

  def test_hot_items_no_hits
    get('/api?token=token&url=http://test.com')
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(!last_response.body.include?('is-hot'))
    cleanup!
  end

  def test_hot_items_one_hit
    get('/api?token=token&url=http://test.com')
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    get("/#{item.slug}")
    assert_found
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('is-hot'))
    cleanup!
  end

  def test_hot_items_two_hits
    get('/api?token=token&url=http://test.com')
    item = App::Item.where(:url => 'http://test.com').first
    assert(!item.nil?)
    2.times do
      get("/#{item.slug}")
      assert_found
    end
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('is-hot'))
    cleanup!
  end

  def test_hot_items_multiple_hits
    create_links(2)
    item = App::Item.where(:url => 'http://test1.com').first
    assert(!item.nil?)
    get("/#{item.slug}")
    assert_found
    item = App::Item.where(:url => 'http://test2.com').first
    assert(!item.nil?)
    get("/#{item.slug}")
    assert_found
    authorize('user', 'pass')
    get('/admin')
    assert_ok
    assert(last_response.body.include?('is-hot'))
    cleanup!
  end

  def test_help_links
    authorize('user', 'pass')
    get('/admin#help')
    assert_ok
    assert(last_response.body.include?("#{ENV['SHORT']}/api?token=#{ENV['TOKEN']}&url=%@"))
    assert(last_response.body.include?("#{ENV['SHORT']}/api?token=#{ENV['TOKEN']}"))
  end
end