#--
###############################################################################
#                                                                             #
# flattendb -- Flatten relational databases                                   #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013 Jens Wille                                               #
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

require 'flattendb/version'

module FlattenDB

  autoload :Base,  'flattendb/base'
  autoload :MDB,   'flattendb/types/mdb'
  autoload :MySQL, 'flattendb/types/mysql'

  extend self

  def [](type)
    Base[type]
  end

end
