install: clean build
	cp mail ~/.local/share/bin/mail
	cp fetch-mail ~/.local/share/bin/checkmail
build:
	dmd mail.d -of=mail -L=-lcurl

clean:
	rm -rf *.o dmond
