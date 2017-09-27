#!/usr/bin/perl

use strict;
use Switch;

# --------- base config -------------
##my $ZabbixServer = "1.2.3.4";
##my $HostName = "HostName";
my $ZConfig = "/etc/zabbix/zabbix_agentd.conf";
my $ZSender= "/usr/bin/zabbix_sender";
my $Supervisor = "/usr/local/bin/supervisorctl";
# ----------------------------------


switch ($ARGV[0])
{
case "discovery" {
my $first = 1;

print "{\n";
print "\t\"data\":[\n\n";


my $result = `$Supervisor status`;

my @lines = split /\n/, $result;
foreach my $l (@lines) {
        my @stat = split / +/, $l;
#        my $status = substr($stat[1], 0, -1);

                print ",\n" if not $first;
                $first = 0;

                print "\t{\n";
                print "\t\t\"{#NAME}\":\"$stat[0]\",\n";
                print "\t\t\"{#STATUS}\":\"$stat[1]\"\n";
                print "\t}";
}

print "\n\t]\n";
print "}\n";
}

case "status" {
my $result = `$Supervisor pid`;

if ( $result =~ m/^\d+$/ ) {
		$result = `$ZSender -c $ZConfig -k "supervisor.status" -o "OK"`;
        print $result;

        $result = `$Supervisor status`;

        my @lines = split /\n/, $result;
        foreach my $l (@lines) {
                my @stat = split / +/, $l;

		$result = `$ZSender -c $ZConfig -k "supervisor.check[$stat[0],Status]" -o $stat[1]`;

                print $result;
        }
}
else {
        # error supervisor not runing
		$result = `$ZSender -c $ZConfig -k "supervisor.status" -o "FAIL"`;
        print $result;
}


}
}
