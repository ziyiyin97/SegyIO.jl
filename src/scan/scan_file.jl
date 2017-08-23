export scan_file

"""
Scan a single SEGY file
"""
function scan_file(file::String, keys::Array{String, 1}, blocksize::Int;
                    chunksize::Int = 1024)
    
    # Put fileheader in memory and read
    s = open(file)
    fh = read_fileheader(s)

    # Calc number of blocks
    fsize = position(seekend(s))
    mem_trace = 240 + fh.ns*4
    mem_block = blocksize*mem_trace
    ntraces_file = Int((fsize - 3600)/mem_trace)
    nblocks_file = Int(ceil(ntraces_file/blocksize))
    scan = Array{BlockScan,1}(nblocks_file)
    count = 1

    # Blocks to load per chunk
    mb2b = 1024^2
    max_blocks_per_chunk = Int(floor(chunksize*mb2b/mem_block))

    # Read at most one full chunk into buffer
    seek(s, 3600)
    
    # For each chunk
    for c in 1:max_blocks_per_chunk:nblocks_file
       
        count = scan_chunk!(s, max_blocks_per_chunk, mem_block, mem_trace,
                            keys, file, scan, count)

    end # c

    return scan
        
end
