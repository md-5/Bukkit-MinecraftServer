#!/usr/bin/perl
package VarNamer;
use strict;
use warnings;

use Data::Dumper;

sub new {
    my $Class = shift;
    my $self = {
        last => {
            byte        => [0, 0, qw|b|],
            char        => [0, 0, qw|c|],
            short       => [1, 0, qw|short|],
            int         => [0, 1, qw|i j k l|],
            boolean     => [0, 1, qw|flag|],
            double      => [0, 0, qw|d|],
            float       => [0, 1, qw|f|],
            File        => [1, 1, qw|file|],
            String      => [0, 1, qw|s|],
            Class       => [0, 1, qw|oclass|],
            Long        => [0, 1, qw|olong|],
            Byte        => [0, 1, qw|obyte|],
            Short       => [0, 1, qw|oshort|],
            Boolean     => [0, 1, qw|obool|],
            Long        => [0, 1, qw|olong|],
        },
        remap => {
            long        => 'int',
        }
    };
    return bless $self, $Class;
}

sub getName {
    my $self = shift;
    my $type = shift;

    my $index = exists $self->{last}{ $type } ? $type : $self->{remap}{$type};
    if (!$index && ($type =~ m/^[A-Z]/ || $type =~ m/(\[|\.\.\.)/)) {
        $type =~ s/\.\.\./[]/;
        $type =~ s/(\[\]){1,}/[]/g;

        my $name = lc $type;
        my $skip = 1;

        if ($type =~ m/\[/) {
            $skip = 1;
            $name = "a$name";
            $name =~ s/[\[\]]//g;
            $name =~ s/\.\.\.//g;
        }

        $self->{last}{ $type } = [0, $skip, $name];
        $index = $type;
    }

    print "No data for type: $type\n" and return $type unless $index;

    my ($id, $skip_zero, @data) = @{$self->{last}{ $index }};
    $self->{last}{$index}[0]++;

    my $amount = scalar @data;

    #print Dumper $self->{last};

    if ($amount == 1) {
        return $data[0] . (!$id && $skip_zero ? '' : $id);
    } else {
        my $num = int($id / $amount);
        return $data[ int($id % $amount) ] . (!$num && $skip_zero ? '' : $num );
    }
}

package main;
use strict;
use warnings;

use Data::Dumper;

my $file_name = shift;

my @lines = do {
    open my $fh, '<', $file_name or die $!;
    <$fh>;
};

open my $oh, '>', $file_name.".new";

my $inside_method = 0;
my $method = '';
my @method_variables;
my $skip = 0;
for (@lines) {
    if (/^ {4}\S.*(?:\{|\);|})$/ && !m/=/ && !m/\(.*\(/) {
        push @method_variables, map { s/^\s*|\s*$//g; $_ } split /,/, (m/\((.+)\)/)[0] if m/\(.+\)/;

        $method .= $_;

        ## Could be single-line
        $skip = 1;
        if (m/(}|\);)$/) {
        } else {
            $inside_method = 1;
        }
    } elsif(/^ {4}}$/) {
        $inside_method = 0;
    }

    if ($inside_method) {
        if ($skip) {
            $skip = 0;
            next;
        }
        $method .= $_;
        if ( m/catch \((.*)\) {/ ) {
            push @method_variables, $1;
        } else {
            #print;
            push @method_variables, grep {
                !/^(return)/
            } m/([a-z_$][a-z0-9_\[\]]+ var\d+)/ig;
        }
    } else {
        if ($method) {
            #print Dumper \@method_variables;
            my $namer = VarNamer->new;
            my @todo = map { [$_ => $namer->getName( (split / /, $_)[0] )] } @method_variables;
            #print Dumper \@todo;

            for (reverse @todo) {
                my ($from, $to) = @$_;
                $from = (split / /, $from)[1];

                $method =~ s{\Q$from\E}{$to}g;
            }
            #print "M ".$method;
            print $oh $method;

            $method = '';
            @method_variables = ();
        }

        if ($skip) {
            $skip = 0;
            next;
        }

        #print "O ".$_;
        print $oh $_;
    }
}
