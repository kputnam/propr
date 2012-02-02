require "pathname"
abspath = Pathname.new(File.dirname(__FILE__)).expand_path
relpath = abspath.relative_path_from(Pathname.pwd)

begin
  require "rubygems"
  require "bundler/setup"
rescue LoadError
  warn "couldn't load bundler:"
  warn "  #{$!}"
end

task :console do
  exec *%w(irb -I lib -r markup)
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new do |t|
    t.verbose = false
    t.pattern = "#{relpath}/spec/examples/**/*.example"

    t.rspec_opts  = %w(--color --format p)
    t.rspec_opts << "-I#{abspath}/spec"
  end
rescue LoadError
  task :spec do
    warn "couldn't load rspec"
    warn "  #{$!}"
    exit 1
  end
end

begin
  require "rcov"
  begin
    require "rspec/core/rake_task"
    RSpec::Core::RakeTask.new(:rcov) do |t|
      t.rcov = true
      t.rcov_opts = "--exclude spec/,gems/,00401"

      t.verbose = false
      t.pattern = "#{relpath}/spec/examples/**/*.example"

      t.rspec_opts  = %w(--color --format p)
      t.rspec_opts << "-I#{abspath}/spec"
    end
  rescue LoadError
    task :rcov do
      warn "couldn't load rspec"
      warn "  #{$!}"
      exit 1
    end
  end
rescue LoadError
  task :rcov do
    warn "couldn't load rcov:"
    warn "  #{$!}"
    exit 1
  end
end

begin
  require "yard"

  # Note options are loaded from .yardopts
  YARD::Rake::YardocTask.new(:yard => :clobber_yard)

  task :clobber_yard do
    rm_rf "#{relpath}/doc/generated"
    mkdir_p "#{relpath}/doc/generated/images"
  end
rescue LoadError
  task :yard do
    warn "couldn't load yard:"
    warn "  #{$!}"
    exit 1
  end
end

task :default => :spec
