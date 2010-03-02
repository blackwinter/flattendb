#--
###############################################################################
#                                                                             #
# A component of flattendb, the relational database flattener.                #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50923 Cologne, Germany                                   #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# flattendb is free software; you can redistribute it and/or modify it under  #
# the terms of the GNU General Public License as published by the Free        #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# flattendb is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for    #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with flattendb. If not, see <http://www.gnu.org/licenses/>.                 #
#                                                                             #
###############################################################################
#++

require 'yaml'

require 'rubygems'
require 'builder'

module FlattenDB

  class Base

    @types = {}

    BUILDER_OPTIONS = {
      :xml => {
        :indent => 2
      }
    }

    # cf. <http://www.w3.org/TR/2006/REC-xml-20060816/#NT-Name>
    ELEMENT_START = %r{^[a-zA-Z_:]}
    ELEMENT_CHARS = %q{\w:.-}

    class << self

      def types
        Base.instance_variable_get :@types
      end

      def [](type)
        types[type]
      end

      protected

      def inherited(klass)
        types[klass.name.split('::')[1..-1].join('/').downcase.to_sym] = klass
      end

    end

    attr_reader :root, :config, :input, :output

    def initialize(infiles, outfile, config)
      config = case config
        when Hash
          config
        when String
          # assume file name
          YAML.load_file(config)
        else
          raise ArgumentError, "invalid config argument of type '#{config.class}'"
      end
      raise ArgumentError, "can't have more than one primary (root) table" if config.size > 1

      (@root, @config), _ = *config  # get "first" (and only) hash element

      @input = [*infiles].map { |infile|
        case infile
          when String
            infile
          when File
            infile.path
          else
            raise ArgumentError, "invalid infile argument of type '#{infile.class}'"
        end
      }

      @output = case outfile
        when IO
          outfile
        when String
          # assume file name
          File.open(outfile, 'w')
        else
          raise ArgumentError, "invalid outfile argument of type '#{outfile.class}'"
      end
    end

    def flatten!(*args)
      raise NotImplementedError, 'must be defined by sub-class'
    end

    def to_xml(*args)
      raise NotImplementedError, 'must be defined by sub-class'
    end

    private

    def initialize_builder(type, output, builder_options = {})
      builder_options = (BUILDER_OPTIONS[type] || {}).merge(builder_options)

      @builder = case type
        when :xml
          Builder::XmlMarkup.new(builder_options.merge(:target => output))
        else
          raise ArgumentError, "builder of type '#{type}' not supported"
      end
    end

    # mysql:: <http://dev.mysql.com/doc/refman/5.0/en/identifiers.html>
    def column_to_element(column)
      element = column.dup

      element.insert(0, '_') unless element =~ ELEMENT_START
      element.gsub!(/[^#{ELEMENT_CHARS}]/, '')

      element
    end

  end

end
