guard('rake', :task => 'default') do
  watch(%r{^app.rb})
  watch(%r{^test/(.+)\.rb$}) { |t| "test/#{t[1]}_test.rb" }
end