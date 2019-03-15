import std.format, std.stdio, std.process, std.string, std.concurrency, std.typecons;
import core.stdc.stdlib, core.sys.posix.unistd;

struct MailRes { string res; };
struct TimeRes { string res; };

class Root {
  string time;
  string mail;

  string f() {
    auto ret = format("%s | %s", this.time, this.mail);
    writeln(ret);
    return ret;
  }
}

void mailRunner (string cmd, Tid parent) {
  while (true) {
    auto mailProc = execute(cmd);

    auto res = MailRes( mailProc.output );
    send(parent, res);
    sleep(30);
  }
}

void timeRunner(Tid parent) {
  import std.datetime;

  while (true) {
    writeln("getting time");
    auto time = Clock.currTime();
    writeln("got time");
    auto ret = TimeRes(format("%s:%s", time.hour, time.minute));
    writeln("sending time");
    send(parent, ret);
    sleep(59);
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
        }
        );

  }
}
