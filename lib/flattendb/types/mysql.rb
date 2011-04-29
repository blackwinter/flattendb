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

require 'libxml'

require 'flattendb/base'

module FlattenDB

  class MySQL < Base

    JOIN_KEY = '@key'

    attr_reader :document, :database, :name, :tables, :builder

    def initialize(infile, outfile, config)
      super

      @document = LibXML::XML::Document.file(@input.first)
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
            raise ArgumentError, "invalid join table spec, '#{JOIN_KEY}' missing" unless spec.has_key?(JOIN_KEY)

            join_key_spec = spec.delete(JOIN_KEY)

            joined_tables = tables.dup
            flatten_tables!(joined_tables, foreign_table, spec)

            (join_key_spec.is_a?(Hash) ? join_key_spec : { foreign_table => join_key_spec }).each { |foreign_table_name, join_key|
              local_key, foreign_key = join_key

              inject_foreign(tables, primary_table, foreign_table, local_key, foreign_key || local_key, joined_tables, foreign_table_name)
            }
          else
            raise ArgumentError, "don't know how to handle spec of type '#{spec.class}'"
        end
      }

      tables.delete_if { |table, _|
        table != primary_table
      }
    end

    def inject_foreign(tables, primary_table, foreign_table, local_key, foreign_key = local_key, foreign_tables = tables, foreign_table_name = foreign_table)
      raise ArgumentError, "no such foreign table: #{foreign_table}" unless foreign_tables.has_key?(foreign_table)

      foreign_rows = foreign_tables[foreign_table]

      tables[primary_table].each { |row|
        if row.has_key?(local_key)
          foreign_content = foreign_rows.select { |foreign_row|
            row[local_key] == foreign_row[foreign_key]
          }

          row[foreign_table_name] = foreign_content unless foreign_content.empty?
        end
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
