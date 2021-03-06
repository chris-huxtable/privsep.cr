# Copyright (c) 2018 Christian Huxtable <chris@huxtable.ca>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require "user_group"


class Process

	alias UserTypes = System::User|Int32|UInt32|String
	alias GroupTypes = System::Group|Int32|UInt32|String


	# Changes the root directory and the current working directory for the current
	# process and sets the real, effective, and saved user and group for the current
	# process to the ones specified.
	#
	# ```
	# Process.restrict("/var/empty", "nobody", "nobody")
	# ```
	def self.restrict(path : String? = nil, user : UserTypes? = nil, group : GroupTypes? = nil) : Nil
		user = System::User.get(user) if ( user.is_a?(String) || user.is_a?(Int) )
		group = System::Group.get(group) if ( group.is_a?(String) || group.is_a?(Int) )

		chroot(path) if ( path )

		self.group = group if ( group )
		self.user = user if ( user )
	end

	# Forks the current process then changes the root directory and the current working
	# directory and sets the real, effective, and saved user and group to the ones
	# specified before yielding to the given block.
	#
	# ```
	# Process.restrict("/var/empty", "nobody", "nobody", wait: true) {
	#   # New restricted process
	# }
	# ```
	def self.restrict(path : String? = nil, user : UserTypes? = -1, group : GroupTypes? = -1, wait : Bool = true, &block) : Process?
		proc = Process.fork() {
			restrict(path, user, group)
			yield()
		}

		return proc if ( !wait )

		proc.wait
		return nil
	end

end
