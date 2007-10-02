#--
###############################################################################
#                                                                             #
# A component of flattendb, the relational database flattener.                #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
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
require 'xml/libxml'

require 'flattendb/base'

module FlattenDB

  class MySQL < Base

    attr_reader :root, :config, :output, :document, :database, :name, :tables, :builder

    def initialize(infile, outfile, config)
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

      @output = case outfile
        when IO
          outfile
        when String
          # assume file name
          File.open(outfile, 'w')
        else
          raise ArgumentError, "invalid outfile argument of type '#{outfile.class}'"
      end

      @document = XML::Document.file(case infile
        when String
          infile
        when File
          infile.path
        else
          raise ArgumentError, "invalid infile argument of type '#{infile.class}'"
      end)

      @database = @document.root.find_first('database[@name]')
      @name     = @database[:name]
      @tables   = {}

      parse
    end

    def flatten!(options = {}, builder_options = {})
      flatten_tables!(tables, root, config)

      self
    end

    def to_xml(output = output, builder_options = {})
      initialize_builder(:xml, output, builder_options)

      builder.instruct!

      if tables.size > 1
        builder.tag!(name) {
          tables.sort.each { |table, rows|
            table_to_xml(table, rows, builder)
          }
        }
      else
        (table, rows), _ = *tables  # get "first" (and only) hash element
        table_to_xml(name, rows, builder)
      end

      self
    end

    private

    def parse
      database.find('table_data[@name]').each { |table|
        rows = []

        table.find('row').each { |row|
          fields = {}

          row.find('field[@name]').each { |field|
            fields[field[:name]] = field.content
          }

          rows << fields
        }

        tables[table[:name]] = rows
      }
    end

    def flatten_tables!(tables, primary_table, config)
      config.each { |foreign_table, spec|
        case spec
          when String
            inject_foreign(tables, primary_table, foreign_table, spec)
          when Array
            inject_foreign(tables, primary_table, foreign_table, *spec)
          when Hash
            local_key, foreign_key = spec.delete('@key')
            foreign_key ||= local_key

            joined_tables = tables.dup
            flatten_tables!(joined_tables, foreign_table, spec)

            inject_foreign(tables, primary_table, foreign_table, local_key, foreign_key, joined_tables)
          else
            raise ArgumentError, "don't know how to handle spec of type '#{spec.class}'"
        end
      }

      tables.delete_if { |table, _|
        table != primary_table
      }
    end

    def inject_foreign(tables, primary_table, foreign_table, local_key, foreign_key = local_key, foreign_tables = tables)
      tables[primary_table].each { |row|
        next unless row.has_key?(local_key)

        foreign_content = foreign_tables[foreign_table].find_all { |foreign_row|
          row[local_key] == foreign_row[foreign_key]
        }

        row[foreign_table] = foreign_content unless foreign_content.empty?
      }
    end

    def table_to_xml(table, rows, builder)
      builder.tag!(table) {
        rows.each { |row|
          row_to_xml('row', row, builder)
        }
      }
    end

    def row_to_xml(name, row, builder)
      builder.tag!(name) {
        row.sort.each { |field, content|
          field_to_xml(field, content, builder)
        }
      }
    end

    def field_to_xml(field, content, builder)
      case content
        when String
          builder.tag!(column_to_element(field), content)
        when Array
          content.each { |item|
            field_to_xml(field, item, builder)
          }
        when Hash
          row_to_xml(field, content, builder)
        else
          raise ArgumentError, "don't know how to handle content of type '#{content.class}'"
      end
    end

  end

end
