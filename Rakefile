require File.expand_path(%q{../lib/flattendb/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :gem => {
      :name         => %q{flattendb},
      :version      => FlattenDB::VERSION,
      :summary      => %q{Flatten relational databases.},
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@gmail.com},
      :license      => %q{AGPL-3.0},
      :homepage     => :blackwinter,
      :dependencies => %w[builder cyclops libxml-ruby mysql_parser] << ['ruby-nuggets', '>= 0.9.2']
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
