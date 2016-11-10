#!/usr/bin/perl

use strict;
use Switch;

# --------- base config -------------
my $ZabbixServer = "1.2.3.4";
my $HostName = "HostName";
# ----------------------------------

switch ($ARGV[0])
{
case "discovery" {
my $first = 1;

print "{\n";
print "\t\"data\":[\n\n";


my $result = `/usr/bin/supervisorctl status`;

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
my $result = `/usr/bin/supervisorctl pid`;

if ( $result =~ m/^\d+$/ ) {
        $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s $HostName -k "supervisor.status" -o "OK"`;
        print $result;

        $result = `/usr/bin/supervisorctl status`;

        my @lines = split /\n/, $result;
        foreach my $l (@lines) {
                my @stat = split / +/, $l;

                $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s $HostName -k "supervisor.check[$stat[0],Status]" -o $stat[1]`;
                print $result;
        }
}
else {
        # error supervisor not runing
        $result = `/usr/bin/zabbix_sender -z $ZabbixServer -s $HostName -k "supervisor.status" -o "FAIL"`;
        print $result;
}


}
}
