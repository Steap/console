# frozen_string_literal: true
#
# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'console/logger'
require_relative 'console/resolver'
require_relative 'console/terminal/logger'

module Console
	class << self
		attr_accessor :logger
		
		# Set the default log level based on `$DEBUG` and `$VERBOSE`.
		# You can also specify CONSOLE_LEVEL=debug or CONSOLE_LEVEL=info in environment.
		# https://mislav.net/2011/06/ruby-verbose-mode/ has more details about how it all fits together.
		def default_log_level(env = ENV)
			if level = (env['CONSOLE_LEVEL'] || env['CONSOLE_LOG_LEVEL'])
				Logger::LEVELS[level.to_sym] || Logger.warn
			elsif $DEBUG
				Logger::DEBUG
			elsif $VERBOSE.nil?
				Logger::WARN
			else
				Logger::INFO
			end
		end
		
		def default_resolver(logger, env = ENV)
			if names = env['CONSOLE_DEBUG']&.split(',')
				resolver = Resolver.new
				
				resolver.bind(names) do |klass|
					logger.enable(klass, Logger::DEBUG)
				end
				
				return resolver
			end
		end
		
		# Controls verbose output using `$VERBOSE`.
		def verbose?
			!$VERBOSE.nil?
		end
		
		def build(output, verbose: self.verbose?, level: self.default_log_level)
			terminal = Terminal::Logger.new(output, verbose: verbose)
			
			logger = Logger.new(terminal, verbose: verbose, level: level)
			
			return logger
		end
	end
	
	# Create the logger instance:
	@logger = self.build($stderr)
	@resolver = self.default_resolver(@logger)
	
	def logger= logger
		@logger = logger
	end
	
	def logger
		@logger || Console.logger
	end
	
	def self.extended(klass)
		klass.instance_variable_set(:@logger, nil)
	end
end
