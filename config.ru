require './app.rb'

# This passes requests to the root into the folder using rack-rewrite.
# Apache and Nginx do this too, but you may want to do it here.
# e.g. `http://exam.pl/e` -> `http://example.com`
#
# require 'rack/rewrite'
# use Rack::Rewrite do
#   r301 '/', '/e'
# end

# Just in case you want to put this into a folder just use `map`.
# You need to tweak your `.env` SHORT variable also.
# e.g. `SHORT = 'http://exam.pl/e'`
#
# map '/e' do
#   run App
# end

# The default is not to use folders.
# e.g. `http://exam.pl` -> `http://example.com`
#
run App