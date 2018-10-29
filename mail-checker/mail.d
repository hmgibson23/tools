import etc.c.curl;
import core.stdc.stdio, std.string, std.stdio : writeln;

void main(string[] args)
{
  if (args.length != 3) {
    writeln("Useage: mail <username> <password>");
  }
  CURL *curl;
  CURLcode res ;

  auto username = args[1];
  auto password = args[2];

  curl = curl_easy_init();
  if(curl) {
    /* Set username and password */
    curl_easy_setopt(curl, CurlOption.username, toStringz(username));
    curl_easy_setopt(curl, CurlOption.password, toStringz(password));

    /* This will fetch message 1 from the user's inbox. Note the use of
    * imaps:// rather than imap:// to request a SSL based connection. */
    curl_easy_setopt(curl, CurlOption.url,toStringz
                     ( "imaps://imap.gmail.com/" ));

    curl_easy_setopt(curl, CurlOption.customrequest, toStringz( "EXAMINE INBOX" ));
    // curl_easy_setopt(curl, CurlOption.customrequest, toStringz( "SEARCH UNSEEN" ));

    curl_easy_setopt(curl, CurlOption.ssl_verifypeer, 0L);


    curl_easy_setopt(curl, CurlOption.ssl_verifyhost, 0L);

    curl_easy_setopt(curl, CurlOption.verbose, 1L);

    /* Perform the fetch */
    res = curl_easy_perform(curl);

    /* Check for errors */
    if(res != CurlError.ok)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));

    /* Always cleanup */
    curl_easy_cleanup(curl);
  }

}
