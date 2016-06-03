all:
	coffee -o lib/ -c src/

watch:
	coffee -o lib/ -cw src/

clean:
	rm -rf lib/

install:
	mkdir -p /var/apps/RobotKey
	chown pi /var/apps/RobotKey
	chmod a+rw /var/apps/RobotKey
	cp -r ./* /var/apps/RobotKey
	cp robotkey /etc/init.d/robotkey
	chmod 755 /etc/init.d/robotkey
	update-rc.d robotkey defaults
	@echo "reboot to start the service"


.PHONY: all watch clean test
