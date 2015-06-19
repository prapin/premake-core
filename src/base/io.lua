--
-- io.lua
-- Additions to the I/O namespace.
-- Copyright (c) 2008-2014 Jason Perkins and the Premake project
--


--
-- Open an overload of the io.open() function, which will create any missing
-- subdirectories in the filename if "mode" is set to writeable.
--

	local file2name = {}
	
	local function readFile(filename)
		local f = io.open(filename, "rb");
		if f == nil then return end
		local content = f:read("*a");
		f:close()
		return content
	end

	premake.override(getmetatable(io.stdout), "close", function(base, file)
		base(file)
		local name = file2name[file]
		if not name then return end
		file2name[file] = nil
		local tmpName = name .. ".tmp"
		local orig = readFile(name)
		local newer = readFile(tmpName)
		if orig == newer then
			os.remove(tmpName)
		else
			os.remove(name)
			os.rename(tmpName, name)
		end
	end)


	premake.override(io, "open", function(base, fname, mode)
		if mode and mode:find("w") then
			local dir = path.getdirectory(fname)
			ok, err = os.mkdir(dir)
			if not ok then
				error(err, 0)
			end
			local file = base(fname .. ".tmp", mode)
			file2name[file] = fname
			return file
		end
		return base(fname, mode)
	end)


--
-- Output a UTF-8 signature.
--

	function io.utf8()
		io.write('\239\187\191')
	end
