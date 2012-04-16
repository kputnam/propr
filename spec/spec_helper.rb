require "rspec"
require "propr"

# Require supporting files with custom matchers and macros
Pathname.new(File.dirname(__FILE__)).tap do |specdir|
  Dir["#{specdir}/support/**/*.rb"].each do |file|
    require Pathname.new(file).relative_path_from(specdir)
  end
end

RSpec.configure do |config|
  include Propr::RSpec

  #srand 146211424375622429406889408197139382303
  srand.tap{|seed| puts "Run with srand #{seed}"; srand seed }

  # rspec -I lib -t random spec
  # config.filter_run :random => true

  # rspec -I lib -t ~random spec
  # config.filter_run_excluding :random => true
  # config.filter_run(:focus  => true)

end
