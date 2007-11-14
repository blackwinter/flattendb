# Utilizes global rake-tasks: alias rake="rake -r rake -R /path/to/rakelibdir"
# (Base tasks at <http://prometheus.khi.uni-koeln.de/svn/scratch/rake-tasks/>)

require 'lib/flattendb/version'

FILES = FileList['lib/**/*.rb'].to_a
EXECS = FileList['bin/*'].to_a
RDOCS = %w[README COPYING ChangeLog]
OTHER = FileList['[A-Z]*', 'example/*'].to_a

task(:doc_spec) {{
  :title      => 'flattendb Application documentation',
  :rdoc_files => RDOCS + FILES
}}

task(:gem_spec) {{
  :name             => 'flattendb',
  :version          => FlattenDB::VERSION,
  :summary          => 'Flatten relational databases',
  :files            => FILES + EXECS + OTHER,
  :require_path     => 'lib',
  :bindir           => 'bin',
  :executables      => EXECS,
  :extra_rdoc_files => RDOCS,
  :dependencies     => %w[highline libxml-ruby builder ruby-nuggets]
}}
