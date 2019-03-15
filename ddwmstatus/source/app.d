import std.format, std.stdio, std.process, std.string, std.concurrency, std.typecons;
import core.stdc.stdlib, core.sys.posix.unistd;

struct MailRes { string res; };
struct TimeRes { string res; };
struct BatteryRes { string res; };

class Root {
  string time;
  string mail;
  string battery;

  string f() {
    auto ret = format("%s | %s | %s", this.time, this.mail, this.battery);
    writeln(ret);
    return ret;
  }
}

void mailRunner (string cmd, Tid parent) {
  while (true) {
    auto mailProc = execute(cmd);

    if (mailProc.status == 0) {
      auto res = MailRes( mailProc.output );
      send(parent, res);
    }

    sleep(30);
  }
}

void timeRunner(Tid parent) {
  import std.datetime;

  while (true) {
    auto time = Clock.currTime();
    string min;
    if ( time.minute < 10 ) {
      min = format("%s:0%s", time.hour, time.minute);
    } else {

      min = format("%s:%s", time.hour, time.minute);
    }

    auto ret = TimeRes(min);

    send(parent, ret);
    sleep(59);
  }
}

void batteryRunner(Tid parent) {
  import battery.d;
  while(true) {
    auto b = new Battery();
    int o = cast(int)b.level;
    auto ret = BatteryRes(format("%d", o));
    writeln("Level: ", b.level);
    send(parent, ret);
    sleep(10);
  }
}

void xrootcmd(string val) {
  auto ret = format("xsetroot -name \"%s\"", val);
  writeln(ret);
  executeShell(ret);
}

void main (string [] args) {
  const auto mail = "checkmail";
  spawn(&timeRunner, thisTid);
  spawn(&batteryRunner, thisTid);
  spawn(&mailRunner, mail, thisTid);

  auto root = new Root();
  while (true) {
    receive(
        (MailRes mail) {
        root.mail = mail.res;
        xrootcmd(root.f());
        },
        (TimeRes time) {
        root.time = time.res;
        xrootcmd(root.f());
        },
        (BatteryRes batt) {
        root.battery = batt.res;
        xrootcmd(root.f());
        }
        );

  }
}
