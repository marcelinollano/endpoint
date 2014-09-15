require_relative 'test_helper.rb'

class PurgeTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::Test::Utils

  def app; App; end

  def test_purge
    env = [
      "RACK_ENV=#{ENV['RACK_ENV']}",
      "MEDIA=#{ENV['MEDIA']}",
      "TOKEN=#{ENV['TOKEN']}",
      "SHORT='http://localhost:3000/'"
    ].join(' ')

    pid = spawn("#{env} rackup -p 3000 -E test", :err => '/dev/null')

    create_media(5)
    items = App::Item.all
    assert_equal(5, items.length)
    system("#{env} PURGE=0 ./bin/purge")
    items = App::Item.all
    assert_equal(0, items.length)

    create_media(1)
    items = App::Item.all
    assert_equal(1, items.length)
    item = App::Item.first
    time = Time.now - 86400
    item.update(:created_at => time)
    item = App::Item.where(:created_at => time).all
    assert_equal(1, item.length)
    system("#{env} PURGE=1 ./bin/purge")
    items = App::Item.all
    assert_equal(0, items.length)

    create_media(4)
    items = App::Item.all
    assert_equal(4, items.length)
    item = App::Item.first
    time = Time.now - (7 * 86400)
    item.update(:created_at => time)
    item = App::Item.where(:created_at => time).all
    assert_equal(1, item.length)
    system("#{env} PURGE=5 ./bin/purge")
    items = App::Item.all
    assert_equal(3, items.length)

    cleanup!
    Process.kill(9, pid);
  end
end