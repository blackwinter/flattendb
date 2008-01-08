begin
  require 'hen'
rescue LoadError
  abort "Please install the 'hen' gem first."
end

require 'lib/flattendb/version'

Hen.lay! {{
  :rubyforge => {
    :package => 'flattendb'
  },

  :gem => {
    :version      => FlattenDB::VERSION,
    :summary      => 'Flatten relational databases.',
    :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
    :extra_files  => FileList['[A-Z]*', 'example/*'].to_a,
    :dependencies => %w[highline libxml-ruby builder ruby-nuggets]
  }
}}
