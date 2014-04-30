#--
###############################################################################
#                                                                             #
# A component of flattendb, the relational database flattener.                #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013-2014 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
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
require 'mysql_parser'
require 'flattendb'

module FlattenDB

  class MySQL < Base

    JOIN_KEY = :@key

    attr_reader :type, :name, :tables, :builder

    def initialize(options)
      super

      @type = options[:type] || :xml
      @name, @tables = parse
    end

    def parse(tables = {})
      [send("parse_#{type}", tables) || 'root', tables]
    end

    def flatten!(options = {})
      flatten_tables!(tables, root, config)
      self
    end

    def to_xml(output = output, builder_options = {})
      initialize_builder(:xml, output, builder_options)

      builder.instruct!

      if tables.size > 1
        builder.tag!(name) {
          tables.sort.each { |table, rows| table_to_xml(table, rows, builder) }
        }
      else
        table_to_xml(name, tables.values.first, builder)
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
      name = nil

      MysqlParser.parse(input) { |event, *args|
        case event
          when :use
            raise 'dump file contains more than one database' if name
            name = args.first
          when :insert
            fields, _, table, columns, values = {}, *args

            values.each_with_index { |value, index|
              if column = columns[index]
                fields[column] = value.to_s
              end
            }

            (tables[table] ||= []) << fields
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
            unless spec.key?(JOIN_KEY)
              raise ArgumentError,
                "invalid join table spec, #{JOIN_KEY.inspect} missing"
            end

            unless (join_key_spec = spec.delete(JOIN_KEY)).is_a?(Hash)
              join_key_spec = { foreign_table => join_key_spec }
            end

            foreign_tables = Marshal.load(Marshal.dump(tables))
            flatten_tables!(foreign_tables, foreign_table, spec)

            join_key_spec.each { |foreign_table_name, join_key|
              local_key, foreign_key = join_key

              inject_foreign(
                tables, primary_table, foreign_table,
                local_key, foreign_key || local_key,
                foreign_tables, foreign_table_name
              )
            }
          else
            raise ArgumentError,
              "don't know how to handle spec of type #{spec.class}"
        end
      } if config

      tables.delete_if { |table, _| table != primary_table }
    end

    def inject_foreign(
      tables, primary_table, foreign_table,
      local_key, foreign_key = local_key,
      foreign_tables = tables, foreign_table_name = foreign_table
    )
      unless tables.key?(primary_table)
        raise ArgumentError, "no such primary table: #{primary_table}"
      end

      unless foreign_tables.key?(foreign_table)
        raise ArgumentError, "no such foreign table: #{foreign_table}"
      end

      foreign_rows = Hash.new { |h, k| h[k] = [] }

      foreign_tables[foreign_table].each { |foreign_row|
        foreign_rows[foreign_row[foreign_key]] << foreign_row
      }

      tables[primary_table].each { |row|
        if row.key?(local_key)
          rows = foreign_rows[row[local_key]]
          row[foreign_table_name] = rows unless rows.empty?
        end
      }
    end

    def table_to_xml(table, rows, builder)
      builder.tag!(table) {
        rows.each { |row| row_to_xml('row', row, builder) } if rows
      }
    end

    def row_to_xml(name, row, builder)
      builder.tag!(name) {
        row.sort.each { |field, value| field_to_xml(field, value, builder) }
      }
    end

    def field_to_xml(field, value, builder)
      case value
        when String, Numeric, true, false, nil
          builder.tag!(column_to_element(field), value)
        when Array
          value.each { |item| field_to_xml(field, item, builder) }
        when Hash
          row_to_xml(field, value, builder)
        else
          raise ArgumentError,
            "don't know how to handle value of type #{value.class}"
      end
    end

  end

end
