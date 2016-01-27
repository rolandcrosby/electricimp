function parseCommand(command, args) {
    local argArray = split(args, ",");
    local out = {};
    for (local i = 0; i < argArray.len(); i += 1) {
        argArray[i] = argArray[i].tointeger();
    }
    if ((command == "setColor") && (argArray.len() == 3)) {
        out.command <- "setColor";
        out.args <- argArray;
        return out;
    }
    if ((command == "fadeToColor") && (argArray.len() == 4)) {
        argArray[3] = argArray[3] / 1000.0;
        out.command <- "fadeToColor";
        out.args <- argArray;
        return out;
    }
    return false;
}

function requestHandler(request, response) {
    local responseText = "";
    try {
        if ("command" in request.query && "args" in request.query) {
            local parsedCommand = parseCommand(request.query.command, request.query.args);
            if (parsedCommand == false) {
                responseText = "Invalid command or arguments";
            } else {
                device.send("runCommand", parsedCommand);
                responseText = "Command sent successfully";
            }
        } else {
            responseText = "Invalid query parameters";
        }
        response.send(200, responseText);
    } catch (ex) {
        response.send(500, "Internal Server Error: " + ex);
    }
}

// register the HTTP handler
function setup() {
    http.onrequest(requestHandler);
    server.log(http.agenturl() + "?command=setColor&args=r,g,b");
    server.log(http.agenturl() + "?command=fadeToColor&args=r,g,b,dt (dt in ms)");
}

setup();