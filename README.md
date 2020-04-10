# dnsgraph

####a RRDtool frontend for named (bind) Statistics
    
dnsgraph is a very simple named statistics RRDtool frontend for BIND
that produces daily, weekly, monthly and yearly graphs of 
success/failure, recursion/referral, nxrrset/nxdomain (DNS traffic).

![](/docs/sample/screenshot.png) 

### files:
	dnsgraph.cron
	/etc/default/dnsgraph
	/usr/local/bin/dnsgraph.sh
	/usr/local/bin/dnsanalise.pl
	/usr/local/bin/dnsreport.pl

### Get it from:
    http://www.github.com/meirm/dnsgraph.git

### Required Modules
----------------
- rrdtool and it's perl module (RRDs)
  -> http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/

- File::Tail (which requires Time::HiRes)
  -> get it from CPAN

Note that several Linux distributions will already have these modules as RPMs.

#### Debian:
	apt install rrdtool ribfile-tail-perl


### Usage
dnsgraph is made of two Perl scripts and one bash script:

- dnsanalise.pl

  This script does parse named-stats.log and updates the RRD database
  (named-stats.rrd). 
  
  DO NOT RUN IT WITH CRON WITHOUT -c PARAMETER!

  usage: dnsanalise.pl \[*options*\]
  
  	-c, --cat			#  causes the logfile to be only read and not monitored
  	-r, --rrndfile f	#  rrnd databaset
  	-l, --logfile f		#  monitor logfile f instead of default
  	-h, --help			#  display this help and exit
  	-v, --version		#  output version information and exit
  
  If -c is not specified, dnsanalise will monitor logfile for stats log
  entries.

- dnsreport.pl

usage: dnsreport.pl \[*options*\]

  	-n, --hostname str   #  Hostname, default is the hostname of the host running the script.
  	-r, --rrndfile f     	#  rrnd databaset
	-i, --images d   	#  directory where to save the rrd images. default: imgs
	-h, --help          	#  display this help and exit
	-v, --version      	#  output version information and exit


  This is a perl script that does generate graphics from the RRD database.

#### Installation

1. Install rndc tool for named.
2. Configure named. Example settings (append to your config):
	
		options {
		 	statistics-file "named-stats.log";
		}
		
		key "rndc-key" {
		    algorithm hmac-md5;
		    secret "!@#your-secret-key!@#";
		};
		
		controls {
			inet 127.0.0.1 port 953
			allow { 127.0.0.1; } keys { "rndc-key"; };
		};
						
3. Configure rndc tool. Example /etc/bind/rndc.conf
		
		key "rndc-key" {
		    algorithm hmac-md5;
		    secret "!@#your-secret-key!@#";
		};
				
		options {
		    default-key "rndc-key";
		    default-server 127.0.0.1;
		    default-port 953;
		};
			    
4. Check rndc (You may use "rndc stats")

5. Put dnsgraph's scripts in /usr/local/bin.

6. Modify /etc/default/dnsgraph.

7. Put "rndc stats" and "dnsgraph.sh" into crontab.
You may create /etc/cron.d/dnsgraph with:
		
		*/1 * * * *    /usr/sbin/rndc stats
		*/10 * * * *  /usr/local/bin/dnsgraph.sh \
			> /var/lib/named/named-graph.log
		
10. Wait 15 minutes and check charts.


License
-------

dnsgraph is released under the GPL license. See the file LICENSE included in
the distribution for details.

    dnsgraph - a RRDtool frontend for named (bind) Statistics
    by Meir Michanie
    based on dnsgraph
    by Jicheng Qu
    by Przemyslaw Sztoch <navy@navy.wox.org>
    based on dnsgraph by David Schweikert <dws@ee.ethz.ch>