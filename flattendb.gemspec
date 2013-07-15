# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "flattendb"
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2013-07-15"
  s.description = "Flatten relational databases."
  s.email = "jens.wille@gmail.com"
  s.executables = ["flattendb", "flattendb.mdb", "flattendb.mysql"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/flattendb.rb", "lib/flattendb/base.rb", "lib/flattendb/cli.rb", "lib/flattendb/types/mdb.rb", "lib/flattendb/types/mysql.rb", "lib/flattendb/version.rb", "bin/flattendb", "bin/flattendb.mdb", "bin/flattendb.mysql", "COPYING", "ChangeLog", "README", "Rakefile", "example/mysql-sample.flat-sql.xml", "example/mysql-sample.flat.xml", "example/mysql-sample.sql", "example/mysql-sample.xml", "example/mysql-sample2flat.yaml"]
  s.homepage = "http://github.com/blackwinter/flattendb"
  s.licenses = ["AGPL"]
  s.rdoc_options = ["--charset", "UTF-8", "--line-numbers", "--all", "--title", "flattendb Application documentation (v0.2.2)", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.5"
  s.summary = "Flatten relational databases."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.9.2"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0.9.2"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0.9.2"])
  end
end
