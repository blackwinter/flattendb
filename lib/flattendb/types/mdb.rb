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

require 'fastercsv'
require 'nuggets/file/which'
require 'flattendb'

module FlattenDB

  class MDB < Base

    def initialize(options)
      super
      parse
    end

    def parse
      tables_cmd, export_cmd = 'mdb-tables', 'mdb-export'

      [tables_cmd, export_cmd].each { |cmd|
        next if File.which(cmd)
        abort "Command not found: #{cmd}! Please install `mdbtools' first."
      }

      # ...
    end

    def flatten!(options = {}, builder_options = {})
      self
    end

    def to_xml(output = output, builder_options = {})
      self
    end

  end

end
