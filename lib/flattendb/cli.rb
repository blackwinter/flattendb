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

require 'optparse'
require 'yaml'
require 'zlib'
require 'flattendb'

module FlattenDB

  class CLI

    USAGE = "Usage: #{$0} [-h|--help] [options]"

    DEFAULTS = {
      :input  => '-',
      :inputs => [],
      :output => '-',
      :config => 'config.yaml'
    }

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

    def self.execute(type = nil, *args)
      new(type).execute(*args)
    end

    attr_reader :type, :options, :config, :defaults
    attr_reader :stdin, :stdout, :stderr

    def initialize(type = nil, defaults = DEFAULTS)
      @defaults = defaults

      reset(type)

      # prevent backtrace on ^C
      trap(:INT) { exit 130 }
    end

    def execute(arguments = [], *inouterr)
      reset(type, *inouterr)

      parse_options(arguments, defaults)

      if type
        require "flattendb/types/#{type}"
      else
        abort 'Database type is required!'
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

      abort USAGE unless arguments.empty?

      options[:output] = open_file_or_std(options[:output], true)

      FlattenDB[type].to_flat!(options)
    ensure
      options[:output].close if options[:output].is_a?(Zlib::GzipWriter)
    end

    def reset(type = nil, stdin = STDIN, stdout = STDOUT, stderr = STDERR)
      @stdin, @stdout, @stderr = stdin, stdout, stderr
      self.type, @options, @config = type, {}, {}
    end

    private

    def type=(type)
      if type
        @type = type.to_s.downcase.to_sym
        abort "Database type not supported: #{type}" unless TYPES.has_key?(@type)
      else
        @type = nil
      end
    end

    def open_file_or_std(file, write = false)
      if file == '-'
        write ? stdout : stdin
      else
        gz = file =~ /\.gz\z/i

        if write
          gz ? Zlib::GzipWriter.open(file) : File.open(file, 'w')
        else
          abort "No such file: #{file}" unless File.readable?(file)
          (gz ? Zlib::GzipReader : File).open(file)
        end
      end
    end

    def warn(msg, output = stderr)
      output.puts(msg)
    end

    def abort(msg = nil, status = 1, output = stderr)
      warn(msg, output) if msg
      exit(status)
    end

    def parse_options(arguments, defaults)
      option_parser(defaults).parse!(arguments)

      config_file = options[:config] || defaults[:config]
      @config = YAML.load_file(config_file) if File.readable?(config_file)

      [config, defaults].each { |hash| hash.each { |key, value| options[key] ||= value } }
    end

    def option_parser(defaults)
      sorted_types = TYPES.keys.sort_by { |t| t.to_s }

      OptionParser.new { |opts|
        opts.banner = USAGE

      if type
        opts.separator ''
        opts.separator "TYPE = #{type} (#{TYPES[type][:title]})"
      end

        opts.separator ''
        opts.separator 'Options:'

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

        type ? type_options(opts) : sorted_types.each { |t| type_options(opts, true, t) }

        opts.separator ''
        opts.separator 'Generic options:'

        opts.on('-h', '--help', 'Print this help message and exit') {
          abort opts.to_s
        }

        opts.on('--version', 'Print program version and exit') {
          abort "#{File.basename($0)} v#{FlattenDB::VERSION}"
        }

      unless type
        opts.separator ''
        opts.separator "Supported database types: #{sorted_types.map { |t| "#{t} (#{TYPES[t][:title]})" }.join(', ')}."
      end
      }
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
