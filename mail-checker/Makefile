install: clean build
	cp mail ~/.local/share/bin/mail-check
build:
	dmd mail.d -of=mail -L=-lcurl

clean:
	rm -rf *.o dmond
