import etc.c.curl;
import core.stdc.stdio, std.string, std.stdio : writeln, writefln;
import std.conv : to;

void main(string[] args)
{
  if (args.length != 4) {
    writeln("Useage: mail <imap-server> <username> <password>");
    return;
  }
  CURL *curl;
  CURLcode res ;

  auto imapServer = args[1];
  auto username = args[2];
  auto password = args[3];

  curl = curl_easy_init();
  if(curl) {
    /* username and password */
    curl_easy_setopt(curl, CurlOption.username, toStringz(username));
    curl_easy_setopt(curl, CurlOption.password, toStringz(password));

    curl_easy_setopt(curl, CurlOption.url,toStringz
                     (imapServer));

    curl_easy_setopt(curl, CurlOption.customrequest, toStringz( "STATUS INBOX (UNSEEN)" ));

    // curl_easy_setopt(curl, CurlOption.verbose, 1L);

    /* Perform the fetch */
    res = curl_easy_perform(curl);
    /* Check for errors */
    if(res != CurlError.ok)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));

    curl_easy_cleanup(curl);
  }

}
