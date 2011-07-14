#--
###############################################################################
#                                                                             #
# A component of flattendb, the relational database flattener.                #
#                                                                             #
# Copyright (C) 2007-2011 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# flattendb is free software; you can redistribute it and/or modify it under  #
# the terms of the GNU Affero General Public License as published by the Free #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# flattendb is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License #
# for more details.                                                           #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with flattendb. If not, see <http://www.gnu.org/licenses/>.           #
#                                                                             #
###############################################################################
#++

require 'nuggets/util/cli'
require 'flattendb'

module FlattenDB

  class CLI < ::Util::CLI

    TYPES = {
      :mysql => {
        :title => 'MySQL',
        :opts  => lambda { |opts, options|
          opts.on('-x', '--xml', 'Input file is of type XML [This is the default]') {
            options[:type] = :xml
          }
          opts.on('-s', '--sql', 'Input file is of type SQL') {
            options[:type] = :sql
          }
        }
      },
      :mdb => {
        :title => 'MS Access',
        :opts  => lambda { |opts, options|
          opts.separator("    NOTE: Repeat '-i' for each .mdb file")
        }
      }
    }

    class << self

      def defaults
        super.merge(
          :input  => '-',
          :inputs => [],
          :output => '-',
          :config => 'config.yaml'
        )
      end

      def execute(type = nil, *args)
        new(nil, type).execute(*args)
      end

    end

    attr_reader :type

    def run(arguments)
      if type
        require "flattendb/types/#{type}"
      else
        quit 'Database type is required!'
      end

      options[:input] = if type == :mdb
        if options[:inputs].empty?
          if arguments.empty?
            options[:inputs] << options[:input]
          else
            options[:inputs].concat(arguments)
            arguments.clear
          end
        end

        options[:inputs].map! { |file| open_file_or_std(file) }
      else
        open_file_or_std(
          options[:inputs].last || arguments.shift || options[:input]
        )
      end

      quit unless arguments.empty?

      options[:output] = open_file_or_std(options[:output], true)

      FlattenDB[type].to_flat!(options)
    end

    private

    def init(type)
      super()
      self.type = type
    end

    def type=(type)
      if type
        @type = type.to_s.downcase.to_sym
        quit "Database type not supported: #{type}" unless TYPES.has_key?(@type)
      else
        @type = nil
      end
    end

    def option_parser
      @sorted_types = TYPES.keys.sort_by { |t| t.to_s }
      super
    ensure
      remove_instance_variable(:@sorted_types)
    end

    def pre_opts(opts)
      if type
        opts.separator ''
        opts.separator "TYPE = #{type} (#{TYPES[type][:title]})"
      end
    end

    def opts(opts)
      unless type
        opts.on('-t', '--type TYPE', 'Type of database [REQUIRED]') { |type|
          self.type = type
        }

        opts.separator ''
      end

      opts.on('-i', '--input FILE', 'Input file(s) [Default: STDIN]') { |input|
        (options[:inputs] ||= []) << input
      }

      opts.on('-o', '--output FILE', 'Output file (flat XML) [Default: STDOUT]') { |output|
        options[:output] = output
      }

      opts.on('-c', '--config FILE', "Configuration file (YAML) [Default: #{defaults[:config]}#{' (currently not present)' unless File.readable?(defaults[:config])}]") { |config|
        options[:config] = config
      }

      opts.separator ''
      opts.separator 'Database-specific options:'

      type ? type_options(opts) : @sorted_types.each { |t| type_options(opts, true, t) }
    end

    def post_opts(opts)
      unless type
        opts.separator ''
        opts.separator "Supported database types: #{@sorted_types.map { |t| "#{t} (#{TYPES[t][:title]})" }.join(', ')}."
      end
    end

    def type_options(opts, heading = false, type = type)
      cfg = TYPES[type]

      if heading
        opts.separator ''
        opts.separator " - [#{type}] #{cfg[:title]}"
      end

      cfg[:opts][opts, options]
    end

  end

end
