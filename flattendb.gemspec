# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flattendb}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-04-29}
  s.description = %q{Flatten relational databases.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["flattendb", "flattendb.mdb", "flattendb.mysql"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/flattendb.rb", "lib/flattendb/cli.rb", "lib/flattendb/version.rb", "lib/flattendb/base.rb", "lib/flattendb/types/mysql.rb", "lib/flattendb/types/mdb.rb", "bin/flattendb", "bin/flattendb.mdb", "bin/flattendb.mysql", "README", "ChangeLog", "Rakefile", "COPYING", "example/mysql-sample.flat.xml", "example/mysql-sample2flat.yaml", "example/mysql-sample.xml", "example/mysql-sample.sql"]
  s.homepage = %q{http://prometheus.rubyforge.org/flattendb}
  s.rdoc_options = ["--line-numbers", "--main", "README", "--charset", "UTF-8", "--all", "--title", "flattendb Application documentation (v0.0.7)"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Flatten relational databases.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0"])
    else
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0"])
    end
  else
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0"])
  end
end
