package XML::XForms::Generator::Common;
######################################################################
##                                                                  ##
##  Package:  Common.pm                                             ##
##  Author:   D. Hageman <dhageman@dracken.com>                     ##
##                                                                  ##
##  Description:                                                    ##
##                                                                  ##
##  Perl object to assist in the generation of XML compliant with   ##
##  the W3's XForms specification.                                  ##
##                                                                  ##
######################################################################

##==================================================================##
##  Libraries and Variables                                         ##
##==================================================================##

require 5.6.0;
require Exporter;

use strict;
use warnings;

use Carp;
use XML::LibXML;

our @ISA = qw( Exporter XML::LibXML::Element );

$XML::XForms::Generator::Common::VERSION = "0.3.5";

our @EXPORT = qw( _append_array_data
				  _ensure_xpath
				  @CM_ATTR
				  @NS_ATTR
				  @SN_ATTR
				  $XFORMS_NSPREFIX
				  $XFORMS_NSURI );

## XForms Namespace Variables
our $XFORMS_NSPREFIX = "xforms";
our $XFORMS_NSURI = "http://www.w3.org/2002/01/xforms";

## XForms Common Attributes
our @CM_ATTR = qw( xml:lang class navIndex accessKey );
### XForms Single Node Binding Attributes
our @SN_ATTR = qw( ref model bind );
### XForms Nodeset Binding Attributes
our @NS_ATTR = qw( nodeset model bind );

##==================================================================##
##  Constructor(s)/Deconstructor(s)                                 ##
##==================================================================##

##
##  None.
##

##==================================================================##
##  Method(s)                                                       ##
##==================================================================##

##
##  None.
##

##==================================================================##
##  Function(s)                                                     ##
##==================================================================##

##
##  None.
##

##==================================================================##
##  Internal Function(s)                                            ##
##==================================================================##

##
##  None.
##


##----------------------------------------------##
##  _append_array_data                          ##
##----------------------------------------------##
##  Convience function to analyze an array and  ##
##  append it appropriately.                    ##
##----------------------------------------------##
sub _append_array_data
{
	my $node = shift;

	## Loop through each data piece ...
	foreach( @_ )
	{
		## Look for elements that are 'attachable'.
		if( $_->isa( "XML::LibXML::Node" ) )
		{
			$node->apppendChild( $_ );
		}
		else
		{
			## If we get to this point assume we have appendable text.
			$node->appendText( $_ )
		}
	}

	return;
}

##----------------------------------------------##
##  _ensure_xpath                               ##
##----------------------------------------------##
##  Convience function that will take a xpath   ##
##  and build it if it doesn't exist.           ##
##----------------------------------------------##
sub _ensure_xpath
{
	my( $node, $xpath ) = @_;
	
    ## We need a variable that will hold our search pattern after
	## we build it and also a temporary variable for our loop
	## down below.	
    my( @search );
	my $last = $node;

	## Clean up the XPath a smidgen.
	$xpath =~ s/^\/\///g;

	## Break up the XPath statement into chunks.
	my @path = split( /\//, $xpath );

	foreach( my $loop = 0; $loop < scalar( @path ); $loop++ )
	{
		$search[ $loop ] = "/";

		foreach( my $loop2 = 0; $loop2 <= $loop; $loop2++ )
		{
			$search[ $loop ] .= "/" . $path[ $loop2 ];
		}
	}

	foreach( @search )
	{
		my( $element ) = $node->findnodes( $_ );

		if( defined( $element ) )
		{
			$last = $element;
		}
		else
		{
			## Grab the last part of the XPath expression.
			$_ =~ /\/(\w+)$/;

			## Create the element and append it to the node tree.
			$last = $last->appendChild( XML::LibXML::Element->new( $1 ) );
		}
	}

	return( $last );
}


##==================================================================##
##  End of Code                                                     ##
##==================================================================##
1;

##==================================================================##
##  Plain Old Documentation (POD)                                   ##
##==================================================================##

__END__

=head1 NAME

XML::XForms::Generator::Common

=head1 SYNOPSIS

 use XML::XForms::Common;

=head1 DESCRIPTION

Module is intended for internal XML::XForms::Generator use only.

=head1 METHODS

None.

=head1 AUTHOR

D. Hageman E<lt>dhageman@dracken.comE<gt>

=head1 SEE ALSO

 XML::XForms::Generator
 XML::XForms::Generator::Control
 XML::LibXML
 XML::LibXML::DOM

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2000-2001 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
