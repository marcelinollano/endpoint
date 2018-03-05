require 'rubygems'
require 'bundler'
require 'securerandom'
require 'uri'
require 'fileutils'
Bundler.require
Dotenv.load

# Logs to terminal, I use this to peek into Tweetbot requests.
# Use `puts` inside any action to log to terminal.
#
require 'logger'
class ::Logger; alias_method :write, :<<; end
$stdout.sync = true

class App < Sinatra::Base
  configure do
    # Setups the media folder and creates it if necessary.
    # Does not support nesting.
    #
    set(:media_folder, ENV['MEDIA'])
    path = File.join(settings.public_folder, settings.media_folder)
    Dir.mkdir(path) unless File.exist?(path)

    # Setups and migrates the database.
    # SQLite is used for simplicity, do not judge.
    #
    DB = Sequel.connect("sqlite://db/#{ENV['RACK_ENV']}.sqlite3")
    DB.extension(:pagination)
    DB.create_table?(:items) do
      primary_key :id
      String   :slug
      String   :url
      String   :name
      String   :content
      String   :type
      Integer  :hits
      DateTime :created_at
      DateTime :updated_at
      index    :slug, :unique => true
    end
  end

  # Setups the items model and performs validations.
  # Create and update actions are timestamped.
  #
  class Item < Sequel::Model
    plugin(:timestamps, :update_on_create => true)
    plugin(:validation_helpers)

    def validate
      super
      validates_unique([:url, :slug])
      validates_presence([:url, :slug, :content, :type, :hits])
    end
  end

  helpers do
    # Converts timestamps into a nicer relative date format.
    # Returns the relative date.
    #
    def time_ago(from_time)
      distance_in_minutes = (((Time.now - from_time.to_time).abs)/60).round
      case distance_in_minutes
        when 0..1 then 'Just now'
        when 2..44 then "#{distance_in_minutes} minutes ago"
        when 45..89 then '1 hour ago'
        when 90..1439 then "#{(distance_in_minutes.to_f / 60.0).round} hours ago"
        when 1440..2439 then '1 day ago'
        when 2440..43199 then "#{(distance_in_minutes / 1440).round} days ago"
        when 43200..86399 then '1 month ago'
        when 86400..525599 then "#{(distance_in_minutes / 43200).round} months ago"
        when 525600..1051199 then '1 year ago'
        else "#{(distance_in_minutes / 525600).round} years ago"
      end
    end
  end

  # Admin panel that lists links, tracks hits, deletes files.
  # Protected by HTTP password.
  #
  get('/admin/?') do
    auth_basic!
    begin
      page   = params.has_key?('page') ? params[:page].to_i : 1
      order  = params.has_key?('order') ? params[:order].to_sym : :updated_at
      items  = Item.dataset
      @count = items.count
      @limit = items.count > 0 ? items.max(:hits) - items.avg(:hits).round : 0
      @items = items.order(order).reverse.paginate(page, 25)
      erb(:admin)
    rescue
      bad_request
    end
  end

  # Finds or creates URLs and returns the shortened link.
  # Protected by the API token.
  #
  get('/api/?') do
    auth_token!(params[:token])
    valid_url?(params)
    begin
      item = save_url(params)
      url  = File.join(ENV['SHORT'], item[:slug])
      "#{url}"
    rescue
      bad_request
    end
  end

  # Posts uploads for images, videos and all sort of files.
  # Protected by the API token.
  #
  post('/api/?') do
    auth_token!(params[:token])
    valid_media?(params)
    begin
      item = save_media(params)
      url  = File.join(ENV['SHORT'], "#{item[:slug]}.#{item[:type]}")
      "<mediaurl>#{url}</mediaurl>"
    rescue
      bad_request
    end
  end

  # Deletes items from the database and purges files from disk.
  # Protected by the API token.
  #
  delete('/api/?') do
    auth_token!(params[:token])
    valid_slug?(params)
    item = Item.find(:slug => params[:slug])
    if item
      delete_media(item)
      item.destroy
      "true"
    else
      not_found
    end
  end

  # Retrieves images, videos or files searching by slug and type.
  # Public page.
  #
  get('/:slug.:type') do
    @item = Item.find(:slug => params[:slug], :type => params[:type])
    if @item
      @item.update(:hits => @item.hits.+(1))
      redirect(@item.url)
    else
      not_found
    end
  end

  # Retrieves links, images, videos or files searching by slug.
  # Public page.
  #
  get('/:slug/?*') do
    @item = Item.find(:slug => params[:slug])
    if @item
      @item.update(:hits => @item.hits.+(1))
      case @item.content
        when 'image'       then erb(:image)
        when 'audio'       then erb(:audio)
        when 'video'       then erb(:video)
        when 'application' then erb(:file)
        when 'text'        then redirect(@item.url)
      end
    else
      not_found
    end
  end

  # Redirects to the long URL, your personal website or whatever.
  # Public page.
  #
  get('/?') do
    redirect(ENV['LONG'], 301)
  end

private

  # Protects routes with password, uses a Basic HTTP challenge.
  # Returns 401 if unauthorized.
  #
  def auth_basic!
    auth ||=  Rack::Auth::Basic::Request.new(request.env)
    unless auth.provided? && auth.basic? && auth.credentials && auth.credentials == [ENV['LOGIN'], ENV['PASS']]
      response['WWW-Authenticate'] = %(Basic realm='Restricted Area')
      unauthorized
    end
  end

  # Checks if the token is valid to use the API.
  # Returns 401 if unauthorized.
  #
  def auth_token!(token)
    unless token == ENV['TOKEN']
      unauthorized
    end
  end

  # Checks if the URL is present and valid.
  # Returns 400 if not valid.
  #
  def valid_url?(params)
    unless params[:url] =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/
      bad_request
    end
  end

  # Checks if media and tempfile are present and valid.
  # Returns 400 if not valid.
  #
  def valid_media?(params)
    unless params['media'].is_a?(Hash) && File.exist?(params['media'][:tempfile])
      bad_request
    end
  end

  # Checks if the slug is present and valid.
  # Returns 400 if not valid.
  #
  def valid_slug?(params)
    unless params.has_key?('slug') && !params[:slug].empty?
      bad_request
    end
  end

  # Finds or creates an item's database record from the URL.
  # Returns the item.
  #
  def save_url(params)
    Item.find_or_create(:url => params[:url]) do |item|
      item.set({
        :slug =>    params[:slug] ||= random,
        :url =>     params[:url],
        :name =>    parse(params[:url]),
        :content => 'text',
        :type =>    'html',
        :hits =>    0
      })
    end
  end

  # Creates an item's database record and saves it to disk from media.
  # Returns the item.
  #
  def save_media(params)
    time          = Time.now
    time_folder   = time.strftime('%Y%m%d%H%M%S')
    relative_path = File.join(settings.media_folder, time_folder)
    absolute_path = File.join(settings.public_folder, relative_path)
    tempfile      = params['media'][:tempfile]
    filename      = params['media'][:filename]
    content, type = mime(filename)
    item = Item.create({
      :slug =>       params[:slug] ||= random,
      :url =>        File.join(relative_path, filename),
      :name =>       filename,
      :content =>    content,
      :type =>       type,
      :hits =>       0,
      :created_at => time
    })
    Dir.mkdir(absolute_path)
    File.write(File.join(absolute_path, filename), tempfile.read)
    return item
  end

  # Deletes the associated media folder for an item's database record.
  # Returns nothing.
  #
  def delete_media(item)
    unless item.content == 'text' && item.type == 'html'
      dir = File.join(settings.public_folder, URI(item.url).path.split('/').first(2))
      FileUtils.rm_r(dir) if File.directory?(dir)
    end
  end

  # Generates a random name with custom length.
  # Returns the random name.
  #
  def random
    SecureRandom.hex(ENV['SLUG'].to_i/2)
  end

  # Naive way to find content and type by using Rack::Mime.
  # Returns the content and type.
  #
  def mime(filename)
    content = Rack::Mime.mime_type(File.extname(filename)).split('/')[0]
    type    = File.extname(filename).split('.').last
    return content, type
  end

  # Parses the domain from a URL.
  # Returns the domain.
  #
  def parse(url)
    URI.parse(url).host.gsub(/^www\./, '')
  end

  # Halts 400 with bad request.
  # Returns 400.
  #
  def bad_request
    halt(400, 'Bad Request')
  end

  # Halts 401 when unauthorized.
  # Returns 401.
  #
  def unauthorized
    halt(401, 'Unauthorized')
  end

  # Halts 404 when not found.
  # Returns 404.
  #
  def not_found
    halt(404, 'Not Found')
  end
end