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
      :email        => %q{jens.wille@uni-koeln.de},
      :dependencies => %w[libxml-ruby builder] << ['ruby-nuggets', '>= 0.7.3'] << ['athena', '>= 0.1.5']
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
