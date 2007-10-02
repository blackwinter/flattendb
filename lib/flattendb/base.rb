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

require 'rubygems'
require 'builder'

module FlattenDB

  class Base

    BUILDER_OPTIONS = {
      :xml => {
        :indent => 2
      }
    }

    # cf. <http://www.w3.org/TR/2006/REC-xml-20060816/#NT-Name>
    ELEMENT_START = %r{^[a-zA-Z_:]}
    ELEMENT_CHARS = %q{\w:.-}

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
