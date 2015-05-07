eval 'exec perl -wS $0 ${1+"$@"}' #!/bin/sh -- -*-perl-*-
    if 0;
#-------------------------------------------------------------------------------#

use strict;
# Library used
use Getopt::Std;

#-------------------------------------------------------------------------------
# Print traces for debug
#-------------------------------------------------------------------------------
sub cprint{
    my ($content, $type) = @_;
    my $type_n = "";

    use Term::ANSIColor;    

    if($type == 1){
    	$type_n = "DEBUG\: ";
    }elsif($type == 2){
    	$type_n = "INFO\: ";
    	print color 'blue on_white';
    }elsif($type == 3){
    	$type_n = "CAUTION\: ";
    	print color 'red bold on_white';
    }elsif($type == 4){
    	$type_n = "INFO L2\: ";
    	print color 'green on_white';
    }elsif($type == 5){
    	print color 'bold black on_white';
    }

    print "${type_n}$content";
    print color 'reset';
    print "\n";
}

#-------------------------------------------------------------------------------
# Create pattern with a generic charac and repitition number
#-------------------------------------------------------------------------------
sub CreatePattern{
    my ($line, $char, $nb) = @_;

    $$line  .= sprintf("%s\n","$char"x$nb);
}

#-------------------------------------------------------------------------------
# Get parameters passed to script and return a hash reference to access data
#-------------------------------------------------------------------------------
sub get_options{
    my $opt_string = shift;
    my $check = shift;
    my $opts = {};
    getopts( "$opt_string", $opts );

    my $opt_test = $opt_string;
    $opt_test =~ s/://g;
    my @opt_test = split(//,$opt_test);

    if($check){
	foreach (@opt_test){
	    if(! defined($opts->{$_})){
		print "option -$_ is not defined\n";
	    }
	}
    }

    return $opts;
}

#-------------------------------------------------------------------------------
# Print content in file
#-------------------------------------------------------------------------------
sub printinfile{
    my ($file, $content, $debug) = @_;
    print "$file\n" if defined $debug && $debug == 1;
    open FILE, ">$file" or die $!;
    print FILE $content;
    close(FILE);
}

#-------------------------------------------------------------------------------
# Subroutine to print usage
#-------------------------------------------------------------------------------
sub usage{
    my $usage = shift;
    print "Usage: $0 $usage\n";
}

#-------------------------------------------------------------------------------
# Subroutine to launch test and print ok/failed in color
#-------------------------------------------------------------------------------
sub tof{
    my $condition = shift;
    
    if( $condition eq "failed" ){
	    print color 'red';
	    print "failed";
    } elsif ($condition eq "ok"){
	print color "green";
	print "ok";
    }
    print color 'reset';
    print "]\n";
}


#-------------------------------------------------------------------------------
# Subroutine to end script
#-------------------------------------------------------------------------------
sub sexit{
    print "-- End of $0 --\n";
    exit 0;
}

1;
__END__
# End of gen_utilities.pl
