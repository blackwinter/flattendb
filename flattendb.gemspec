# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flattendb}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jens Wille}]
  s.date = %q{2011-08-16}
  s.description = %q{Flatten relational databases.}
  s.email = %q{jens.wille@gmail.com}
  s.executables = [%q{flattendb}, %q{flattendb.mdb}, %q{flattendb.mysql}]
  s.extra_rdoc_files = [%q{README}, %q{COPYING}, %q{ChangeLog}]
  s.files = [%q{lib/flattendb.rb}, %q{lib/flattendb/cli.rb}, %q{lib/flattendb/version.rb}, %q{lib/flattendb/base.rb}, %q{lib/flattendb/types/mysql.rb}, %q{lib/flattendb/types/mdb.rb}, %q{bin/flattendb}, %q{bin/flattendb.mdb}, %q{bin/flattendb.mysql}, %q{README}, %q{ChangeLog}, %q{Rakefile}, %q{COPYING}, %q{example/mysql-sample.flat.xml}, %q{example/mysql-sample.flat-sql.xml}, %q{example/mysql-sample2flat.yaml}, %q{example/mysql-sample.xml}, %q{example/mysql-sample.sql}]
  s.homepage = %q{http://prometheus.rubyforge.org/flattendb}
  s.rdoc_options = [%q{--main}, %q{README}, %q{--all}, %q{--charset}, %q{UTF-8}, %q{--title}, %q{flattendb Application documentation (v0.1.3)}, %q{--line-numbers}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{Flatten relational databases.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.7.3"])
      s.add_runtime_dependency(%q<athena>, [">= 0.1.5"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0.7.3"])
      s.add_dependency(%q<athena>, [">= 0.1.5"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0.7.3"])
    s.add_dependency(%q<athena>, [">= 0.1.5"])
  end
end
