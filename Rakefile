require File.expand_path(%q{../lib/flattendb/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project => %q{prometheus},
      :package => %q{flattendb}
    },

    :gem => {
      :version      => FlattenDB::VERSION,
      :summary      => %q{Flatten relational databases.},
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@gmail.com},
      :dependencies => %w[builder highline libxml-ruby] << ['ruby-nuggets', '>= 0.9.1']
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
