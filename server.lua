#!/usr/bin/lua

local socket = require("socket")
local t = { ["playlist"] = "playlist", ["discovery"] = "Discovery", ["cartoon"] = "cartoon", ["perviy"] = "первый канал", ["ntv"] = "НТВ", ["sts"] = "СТС", ["stop"] = "trololonome" }

--{{Options
---The port number for the HTTP server. Default is 80
PORT=80
---The parameter backlog specifies the number of client connections
-- that can be queued waiting for service. If the queue is full and
-- another client attempts connection, the connection is refused.
BACKLOG=5
--}}Options

function readAll(file, exe)
    --print("readAll: " .. file)
    local f
    if exe == "x" then
       f = io.popen(file)
    else
       f = io.open(file, "rb")
    end
    local content = f:read("*all")
    f:close()
    return content
end

-- create a TCP socket and bind it to the local host, at any port
server=assert(socket.tcp())
print("PORT " .. PORT)
assert(server:bind("*", PORT))
server:listen(BACKLOG)

-- Print IP and port
local ip, port = server:getsockname()
print("Listening on IP="..ip..", PORT="..port.."...")

local nowplaying=""
-- loop forever waiting for clients
while 1 do
	-- wait for a connection from any client
	local client,err = server:accept()
    print("accepted")
    if client then
        local line, err = client:receive()
        print("line=")
        if not err and line then
                        print("line="..line) 
                        if line:find(".png") or line:find(".ico") then
                           client:send("HTTP/1.1 200 OK\nContent-type: image/png\n\n")
                           client:send(readAll(line:match("/([a-z.]*) ") ))
                        end

                        -- index
                        if line:find("/ ") then
                            client:send("HTTP/1.1 200 OK\nContent-type: text/html; charset: utf-8;\n\n")
                            local index = readAll("index.html")
                            index = index:gsub('{{nowplayingurl}}', readAll("/etc/now_playing.url"))
                            --local log = string.gsub(readAll('tail /tmp/mpv.log', 'x'), "\n", "<br>")
                            --index = index:gsub('{{log}}'          , log)
                            client:send(index)
                        end

                        -- index
                        if line:find("/screenshot.jpg") then
                            client:send("HTTP/1.1 200 OK\nContent-type: image/jpg;\n\n")
                            local jpg = readAll("/tmp/screenshot.jpg")
                            client:send(jpg)
                        end

                        -- play url
                        local url = line:match("play%?url=(.*) ")
                        if url then
                             print("URL url="..url.." line="..line)
                             os.execute("echo '"..url.."' > /etc/now_playing.url; killall mpv; /root/bin/xtext понял")
                             --client:send("HTTP/1.1 302 Found\nLocation: /\n\n")
                        end

                        -- restart
                        if line:find("/restart") then
                             os.execute("/root/bin/xtext restart; killall mpv;")
                             client:send("HTTP/1.1 302 Found\nLocation: /\n\n")
                        end

                        -- stop
                        if line:find("/stop") then
                             os.execute("echo > /tmp/mpv.log; /root/bin/xtext STOP; echo > /root/now_playing.url; killall mpv")
                             client:send("HTTP/1.1 302 Found\nLocation: /\n\n")
                        end
                        client:close()
            else --error
                print("Error happened while getting the connection.nError: "..err)
            end
    end  -- if client

end -- while


