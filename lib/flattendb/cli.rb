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

module FlattenDB

  module CLI

    def require_libraries(*libraries)
      parse_arguments(libraries, :gem).each { |lib, gem|
        begin
          require lib
        rescue LoadError
          abort_with_msg('Ruby library not found: %s', lib, 'Please install gem %s first', gem)
        end
      }
    end

    def require_commands(*commands)
      parse_arguments(commands, :pkg).each { |cmd, pkg|
        catch :cmd_found do
          ENV['PATH'].split(':').each { |path|
            throw :cmd_found if File.executable?(File.join(path, cmd))
          }

          abort_with_msg("Command not found: #{cmd}", "Please install #{pkg} first", pkg || cmd)
        end
      }
    end

    def abort_with_msg(msg1, arg1, msg2, arg2)
      msg  = msg1 % arg1
      msg += " (#{msg2})" % (arg2 || arg1)

      abort msg
    end

    private

    def parse_arguments(arguments, option)
      options = arguments.last.is_a?(Hash) ? arguments.pop : {}
      special = options.delete(option)

      arguments.map { |arg|
        [arg, special]
      } + options.map { |args, spx|
        [*args].map { |arg|
          [arg, spx]
        }
      }.flatten_once
    end

  end

end
