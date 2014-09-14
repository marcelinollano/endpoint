module Rack::Test::Utils
  def create_links(number)
    number.times { |i| get("/api?token=token&url=http://test#{i+1}.com") }
  end

  def create_media(number)
    number.times do |i|
      media = ['image', 'audio', 'video', 'pdf', 'zip']
      post('/api?token=token', 'media' => send(media.sample))
      sleep(0.4)
    end
  end

  def cleanup!
    App::Item.dataset.delete
    dirs = Dir.glob("./public/#{ENV['MEDIA']}/*")
    dirs.each { |f| FileUtils.rm_r(f) if File.directory?(f) }
  end

  # Media fixtures to use with Rack::Test.
  # These are shortcuts to upload files from the fixtures folder.
  #
  def image; Rack::Test::UploadedFile.new('./test/fixtures/shiba.png', 'image/png'); end
  def audio; Rack::Test::UploadedFile.new('./test/fixtures/shiba.mp3', 'audio/mp3'); end
  def video; Rack::Test::UploadedFile.new('./test/fixtures/shiba.mp4', 'video/mp4'); end
  def pdf;   Rack::Test::UploadedFile.new('./test/fixtures/shiba.pdf', 'application/pdf'); end
  def zip;   Rack::Test::UploadedFile.new('./test/fixtures/shiba.zip', 'application/zip'); end
end