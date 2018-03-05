guard('rake', :task => 'default') do
  watch(%r{^app.rb})
  watch(%r{^test/(.+)\.rb$}) { |t| "test/test_#{t[1]}.rb" }
end
