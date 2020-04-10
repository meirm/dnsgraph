#!/usr/bin/perl -w

# dnsgraph -- a bind statistics rrdtool frontend
#
# based on mailgraph by David Schweikert <dws@ee.ethz.ch>
# modified by Jicheng Qu
# modified by Przemyslaw Sztoch <navy@navy.wox.org>
#
# copyright (c) 2003
# released under the GNU General Public License
##################################################

use RRDs;
use POSIX;
use Getopt::Long;

my $VERSION = 0.9;

my $host = `hostname`; chomp $host;
my $xpoints = 600;
my $ypoints = 150;
my $imgs = 'imgs';
my $rrd = '/var/lib/named/named-stats.rrd';

BEGIN {
#   print "Content-Type: text/html\n\n";
    $SIG{__WARN__} = sub { print "<pre>Warning: ".(shift)."</pre>"; };
    $SIG{__DIE__} = sub { print "<pre>Error: ".(shift)."</pre>"; exit 1 }
}

sub graph($$$)
{
	my $range = shift;
	my $file = shift;
	my $title = shift;
	my $img = "$imgs/${file}.png";
	my $time = localtime(time);
	$time =~ s/:/\\:/g;

	my ($graphret,$xs,$ys) = RRDs::graph($img,
		'--imgformat', 'PNG',
		'--width', $xpoints,
		'--height', $ypoints,
		'--start', "-$range",
		'--end', "-".int($range*0.01),
		'--vertical-label', 'queries/hour',
		'--title', "$title of Success vs. Failure",
		'--lazy',
		"DEF:success=$rrd:success:AVERAGE",
		"DEF:failure=$rrd:failure:AVERAGE",
		"DEF:msuccess=$rrd:success:MAX",
		"DEF:mfailure=$rrd:failure:MAX",
		"CDEF:rsuccess=success,3600,*",
		"CDEF:rfailure=failure,3600,*",
		"CDEF:rmsuccess=msuccess,60,*",
		"CDEF:rmfailure=mfailure,60,*",
		"CDEF:vsuccess=success,UN,0,success,IF,$range,*",
		"CDEF:vfailure=failure,UN,0,failure,IF,$range,*",
		'LINE2:rsuccess#000099:Success',
		'GPRINT:vsuccess:AVERAGE:total\: %.0lf queries',
		'GPRINT:rmsuccess:MAX:max\: %.0lf queries/min',
		'AREA:rfailure#009900:Failure',
		'GPRINT:vfailure:AVERAGE:total\: %.0lf queries',
		'GPRINT:rmfailure:MAX:max\: %.0lf queries/min\l',
		'HRULE:0#000000',
		'COMMENT:\s',
		"COMMENT:Graph Created on $time",
	);
	return RRDs::error || "<img border=\"0\" width=\"$xs\" height=\"$ys\" src=\"$img\" alt=\"dnsgraph\" />";

}


sub graph_rr($$$)
{
	my $range = shift;
	my $file = shift;
	my $title = shift;
	my $img = "$imgs/${file}_rr.png";
	my $time = localtime(time);
	$time =~ s/:/\\:/g;

	my ($graphret,$xs,$ys) = RRDs::graph($img,
		'--imgformat', 'PNG',
		'--width', $xpoints,
		'--height', $ypoints,
		'--start', "-$range",
		'--end', "-".int($range*0.01),
		'--vertical-label', 'queries/hour',
		'--title', "$title of Recursion vs. Referral",
		'--lazy',
		"DEF:recursion=$rrd:recursion:AVERAGE",
		"DEF:referral=$rrd:referral:AVERAGE",
		"DEF:mrecursion=$rrd:recursion:MAX",
		"DEF:mreferral=$rrd:referral:MAX",
		"CDEF:rrecursion=recursion,3600,*",
		"CDEF:rreferral=referral,3600,*",
		"CDEF:vrecursion=recursion,UN,0,recursion,IF,$range,*",
		"CDEF:vreferral=referral,UN,0,referral,IF,$range,*",
		"CDEF:rmrecursion=mrecursion,60,*",
		"CDEF:rmreferral=mreferral,60,*",
		'LINE2:rrecursion#000000:Recursion',
		'GPRINT:vrecursion:AVERAGE:total\: %.0lf queries',
		'GPRINT:rmrecursion:MAX:max\: %.0lf queries/min',
		'AREA:rreferral#BB0000:Referral',
		'GPRINT:vreferral:AVERAGE:total\: %.0lf queries',
		'GPRINT:rmreferral:MAX:max\: %.0lf queries/min\l',
		'HRULE:0#000000',
		'COMMENT:\s',
		#'COMMENT:Graph Created on '. ' ' .'\r',
		"COMMENT:Graph Created on $time",
	);
	return RRDs::error || "<img border=\"0\" width=\"$xs\" height=\"$ys\" src=\"$img\" alt=\"dnsgraph\" />";
}

sub graph_nx($$$)
{               
        my $range = shift;
        my $file = shift;
        my $title = shift;
        my $img = "$imgs/${file}_nx.png";
	my $time = localtime(time);
	$time =~ s/:/\\:/g;
                
        my ($graphret,$xs,$ys) = RRDs::graph($img,
                '--imgformat', 'PNG',
                '--width', $xpoints,
                '--height', $ypoints,
                '--start', "-$range",
                '--end', "-".int($range*0.01),
                '--vertical-label', 'queries/hour',
                '--title', "$title of Nxrrset vs. Nxdomain",
                '--lazy',
                "DEF:nxrrset=$rrd:nxrrset:AVERAGE",
                "DEF:nxdomain=$rrd:nxdomain:AVERAGE",
                "DEF:mnxrrset=$rrd:nxrrset:MAX",
                "DEF:mnxdomain=$rrd:nxdomain:MAX",
                "CDEF:rnxrrset=nxrrset,3600,*",
                "CDEF:rnxdomain=nxdomain,3600,*",
                "CDEF:vnxrrset=nxrrset,UN,0,nxrrset,IF,$range,*",
                "CDEF:vnxdomain=nxdomain,UN,0,nxdomain,IF,$range,*",
                "CDEF:rmnxrrset=mnxrrset,60,*",
                "CDEF:rmnxdomain=mnxdomain,60,*",
                'LINE2:rnxrrset#006699:Nxrrset',
                'GPRINT:vnxrrset:AVERAGE:total\: %.0lf queries',
                'GPRINT:rmnxrrset:MAX:max\: %.0lf queries/min',
                'AREA:rnxdomain#ff00ff:Nxdomain',
                'GPRINT:vnxdomain:AVERAGE:total\: %.0lf queries',
                'GPRINT:rmnxdomain:MAX:max\: %.0lf queries/min\l',
                'HRULE:0#000000',
                'COMMENT:\s',
		"COMMENT:Graph Created on $time",
        );
        return RRDs::error || "<img border=\"0\" width=\"$xs\" height=\"$ys\" src=\"$img\" alt=\"dnsgraph\" />";
}

my $day = 3600*24;
my $week = $day*7;
my $month = $day*31;
my $year = $day*365;

sub usage
{
	print "usage: dnsreport [*options*]\n\n";
	print "  -h, --host f       hostname, default: value from /etc/hostname\n";
	print "  -r, --rrdfile f    monitor logfile f instead of $rrd\n";
	print "  -h, --help         display this help and exit\n";
	print "  -v, --version      output version information and exit\n";

	exit;
}

sub print_html{
print <<HEADER;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html>
<head>
<title>DNS Statistics ($host)</title>
</head>
<body>
HEADER

print "<h1>DNS Statistics ($host)</h1>\n";
print "<small><strong>";
print "Summary Period: Last 12 Months<br>\n";
print "Generated ";
print asctime(localtime()) , "\n";
print "</strong></small>";
print "<hr />\n";
print "<h2>Day Stats</h2>\n";
print '<p>', graph($day, "dnsgraph_day", "Day Graph"), "</p>\n";
print '<p>', graph_rr($day, "dnsgraph_day", "Day Graph"), "</p>\n";
print '<p>', graph_nx($day, "dnsgraph_day", "Day Graph"), "</p>\n";
print "<h2>Week Stats</h2>\n";
print '<p>', graph($week, "dnsgraph_week", "Week Graph"), "</p>\n";
print '<p>', graph_rr($week, "dnsgraph_week", "Week Graph"), "</p>\n";
print '<p>', graph_nx($week, "dnsgraph_week", "Week Graph"), "</p>\n";
print "<h2>Month Stats</h2>\n";
print '<p>', graph($month, "dnsgraph_month", "Month Graph"), "</p>\n";
print '<p>', graph_rr($month, "dnsgraph_month", "Month Graph"), "</p>\n";
print '<p>', graph_nx($month, "dnsgraph_month", "Month Graph"), "</p>\n";
print "<h2>Year Stats</h2>\n";
print '<p>', graph($year-$day, "dnsgraph_year", "Year Graph"), "</p>\n";
print '<p>', graph_rr($year-$day, "dnsgraph_year", "Year Graph"), "</p>\n";
print '<p>', graph_nx($year-$day, "dnsgraph_year", "Year Graph"), "</p>\n";

print <<FOOTER;
<p>Generated by <a href="https://github.com/meirm/dnsgraph">DNSGRAPH</a> $VERSION
and <a href="http://people.ee.ethz.ch/~oetiker/webtools/rrdtool">RRDtool</a>.</p>
</body>\n
FOOTER
}

sub main
{
	my %opt = ();
	GetOptions(\%opt, 'help|h', 'images|i=s', 'hostname|n=s', 'rrdfile|r=s', 'version|v') or usage;
	&usage if $opt{help};

	if($opt{help}) {
		&usage();
	}

	if($opt{version}) {
		print "dnsgraph $VERSION\n";
		exit;
	}

	if(defined $opt{hostname}) {
	    $host = $opt{hostname};
	}

	if(defined $opt{images}) {
	    $imgs = $opt{images};
	}

	if(defined $opt{rrdfile}) {
	    $rrd = $opt{rrdfile};
	}
	&print_html();
}

&main();
