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
require 'athena'
require 'flattendb'

module FlattenDB

  class MySQL < Base

    JOIN_KEY = '@key'

    attr_reader :type, :name, :tables, :builder

    def initialize(options)
      super

      @type = options[:type] || :xml
      @name, @tables = parse
    end

    def parse(tables = {})
      [send("parse_#{type}", tables) || 'root', tables]
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

    def parse_xml(tables)
      document = LibXML::XML::Document.io(input)
      database = document.root.find_first('database[@name]')

      database.find('table_data[@name]').each { |table|
        rows = tables[table[:name]] ||= []

        table.find('row').each { |row|
          fields = {}

          row.find('field[@name]').each { |field|
            fields[field[:name]] = field.content
          }

          rows << fields
        }
      }

      database[:name]
    end

    def parse_sql(tables)
      columns, table, name = Hash.new { |h, k| h[k] = [] }, nil, nil
      parser = Athena::Formats::MySQL::SQLParser.new

      input.each { |line|
        case line
          when /\AUSE\s+`(.+?)`/i
            raise 'dump file contains more than one database' if name
            name = $1
          when /\ACREATE\s+TABLE\s+`(.+?)`/i
            table = $1
          when /\A\s+`(.+?)`/
            columns[table] << $1 if table
          when /\A\).*;\Z/
            table = nil
          when /\AINSERT\s+INTO\s+`(.+?)`\s+(?:\((.+?)\)\s+)?VALUES\s*(.*);\Z/i
            _table, _columns, _values = $1, $2, $3

            _columns = _columns.nil? ? columns[_table] :
              _columns.split(/\s*,\s*/).each { |column| column.delete!('`') }

            next if _columns.empty?

            parser.parse(_values) { |row|
              fields = {}

              row.each_with_index { |value, index|
                column = _columns[index] or next
                fields[column] = value.to_s
              }

              (tables[_table] ||= []) << fields
            }
        end
      }

      name
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
      } if config

      tables.delete_if { |table, _| table != primary_table }
    end

    def inject_foreign(tables, primary_table, foreign_table, local_key, foreign_key = local_key, foreign_tables = tables, foreign_table_name = foreign_table)
      raise ArgumentError, "no such foreign table: #{foreign_table}" unless foreign_tables.has_key?(foreign_table)

      foreign_rows = Hash.new { |h, k| h[k] = [] }

      foreign_tables[foreign_table].each { |foreign_row|
        foreign_rows[foreign_row[foreign_key]] << foreign_row
      }

      tables[primary_table].each { |row|
        if row.has_key?(local_key)
          rows = foreign_rows[row[local_key]]
          row[foreign_table_name] = rows unless rows.empty?
        end
      }
    end

    def table_to_xml(table, rows, builder)
      builder.tag!(table) {
        rows.each { |row|
          row_to_xml('row', row, builder)
        } if rows
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
