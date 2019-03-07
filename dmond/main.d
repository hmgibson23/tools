import std.format, std.stdio, std.process, std.string, std.concurrency;
import core.stdc.stdlib, core.sys.posix.unistd;
import core.sys.linux.sys.inotify;

enum PATH_MAX = 256;
enum CHANGED = 1;

// oh no a global
Pid PROCESS;

void watcher(string filename, Tid parent) {
  string chomped = chompPrefix(filename, "./");
  int inotfd = inotify_init();
  auto flags = IN_MODIFY | IN_ATTRIB | IN_DELETE_SELF | IN_MOVE_SELF | IN_IGNORED;
  int watch_desc = inotify_add_watch(inotfd, toStringz(chomped), flags);

  size_t bufsiz = inotify_event.sizeof + PATH_MAX + 1;
  inotify_event* event = cast(inotify_event *) malloc(bufsiz);

  while (true) {
    read(inotfd, event, bufsiz);

    sleep(2);
    send(parent, CHANGED);
  }
}

void restart(string p) {
  writeln("Found change. Restarting...");
  kill(PROCESS);
  PROCESS = spawnProcess(p);
}

void waiter(Tid parent) {
  /* waits on the process and listens for errors */
}

void main (string[] args) {
  if ( args.length < 2 ) {
    writeln("Need something to monitor");
    exit(1);
  }

  auto p = args[1];
  spawn(&watcher, p, thisTid);

  writeln("Monitoring: ", p);
  PROCESS = spawnProcess(p);

  auto done = tryWait(PROCESS);
  if (done.terminated) {
    writeln("Process exited prematurely");
    exit(0);
  }

  while(true) {
    receive(
      (int i) { restart(p); }
      );
  }
}
