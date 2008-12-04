# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flattendb}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2008-12-04}
  s.description = %q{Flatten relational databases.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["flattendb.mysql", "flattendb", "flattendb.mdb"]
  s.extra_rdoc_files = ["COPYING", "ChangeLog", "README"]
  s.files = ["lib/flattendb/types/mdb.rb", "lib/flattendb/types/mysql.rb", "lib/flattendb/cli.rb", "lib/flattendb/version.rb", "lib/flattendb/base.rb", "lib/flattendb.rb", "bin/flattendb.mysql", "bin/flattendb", "bin/flattendb.mdb", "Rakefile", "COPYING", "ChangeLog", "README", "example/mysql-sample.xml", "example/mysql-sample2flat.yaml", "example/mysql-sample.flat.xml", "example/mysql-sample.sql"]
  s.has_rdoc = true
  s.homepage = %q{http://prometheus.rubyforge.org/flattendb}
  s.rdoc_options = ["--main", "README", "--line-numbers", "--inline-source", "--all", "--title", "flattendb Application documentation", "--charset", "UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Flatten relational databases.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
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
