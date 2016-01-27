imp.configure("Hello World", [], []);

clk <- hardware.pin5;
dio <- hardware.pin2;

clk.configure(DIGITAL_OUT);
dio.configure(DIGITAL_OUT);

r_out <- 0;
g_out <- 0;
b_out <- 0;

function ClkRise() {
    clk.write(0);
    imp.sleep(0.000020)
    clk.write(1);
    imp.sleep(0.000020);
}

function TakeAntiCode(dat) {
    return ((dat >> 6) & 0x03);
}

function DatSend(inData) {
    local dx = inData;
    for (local i = 0; i < 32; i += 1) {
        if ((dx & 0x80000000) != 0) {
            dio.write(1);
        } else {
            dio.write(0);
        }
        dx = dx << 1;
        ClkRise();
    }
}

function Validate(num) {
    if (!(num >= 0 && num <= 255)) {return false;}
    if (!(num == math.floor(num))) {return false;}
    return true;
}

function SendColor(r, g, b) {
    if (!(Validate(r) && Validate(g) && Validate(b))) {return false;}
    local dx = 0;
    dx = dx | (0x03 << 30);
    dx = dx | (TakeAntiCode(b) << 28);
    dx = dx | (TakeAntiCode(g) << 26);
    dx = dx | (TakeAntiCode(r) << 24);
    
    dx = dx | (b << 16) | (g << 8) | (r);
    
    server.log("sending: " + dx)
    DatSend(0);
    DatSend(dx);
    DatSend(0);
    return true;
}

function toward(a, b) {
    if (a == b) {return a;}
    if (a > b) {return b + 1;}
    if (a < b) {return b - 1;}
}

function fadeToColor(r, g, b, dt) {
    while ((r != r_out) || (g != g_out) || (b != b_out)) {
        r_out = toward(r, r_out);
        g_out = toward(g, g_out);
        b_out = toward(b, b_out);
        writeColor();
        imp.sleep(dt);
    }
}

function setColor(r, g, b) {
    r_out = r;
    g_out = g;
    b_out = b;
    writeColor();
}

function writeColor() {
    local result = SendColor(r_out, g_out, b_out);
    if (result == false) {setColor(0, 0, 0);}
}

function runCommandHandler(t) {
    if (t.command == "setColor") {setColor(t.args[0], t.args[1], t.args[2]);}
    if (t.command == "fadeToColor") {fadeToColor(t.args[0], t.args[1], t.args[2], t.args[3]);}
}

function registerListeners() {
    agent.on("runCommand", runCommandHandler);
}

function setup() {
    registerListeners();
    setColor(0, 0, 0);
}

setup();