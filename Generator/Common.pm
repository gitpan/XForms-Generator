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

$XML::XForms::Generator::Common::VERSION = "0.4.0";

our @EXPORT = qw( _append_array_data
				  _ensure_xpath
				  @CM_ATTR
				  @NS_ATTR
				  @SN_ATTR
				  %XFORMS_ACTION
				  %XFORMS_EVENT
				  %XFORMS_CONTROL
				  %XFORMS_CONTROL_CHILDREN
				  %XFORMS_MODEL_CHILDREN
				  $XFORMS_NSPREFIX
				  $XFORMS_NSURI );

## XForms Namespace Variables
our $XFORMS_NSPREFIX = "xforms";
our $XFORMS_NSURI = "http://www.w3.org/2002/01/xforms";

## Event Namespace Variable
our $EVENT_NSPREFIX = "ev";
our $EVENT_NSURI = "http://www.w3.org/2001/xml-events";

## XForms Common Attributes
our @CM_ATTR = qw( xml:lang class navIndex accessKey );
### XForms Single Node Binding Attributes
our @SN_ATTR = qw( ref model bind );
### XForms Nodeset Binding Attributes
our @NS_ATTR = qw( nodeset model bind );

## XForms Action Elements with attributes.
our %XFORMS_ACTION = (
	'dispatch'			=>		[ 'name', 'target', 'bubbles', 'cancelable' ],
	'refresh'			=>		[],
	'recalculate'		=>		[],
	'revalidate'		=>		[],
	'setFocus'			=>		[ 'idref' ],
	'loadURI'			=>		[ @SN_ATTR, 'xlink:href', 'xlink:show' ],
	'setValue'			=>		[ @SN_ATTR, 'value' ],
	'submitInstance'	=>		[ 'id', 'submitInfo' ],
	'resetInstance'		=>		[ 'model' ],
	'setRepeatCursor'	=>		[ 'repeat', 'cursor' ],
	'insert'			=>		[ @NS_ATTR, 'at', 'position' ],
	'delete'			=>		[ @NS_ATTR, 'at' ],
	'toggle'			=>		[ 'case' ],
	'script'			=>		[ 'type', 'role' ],
	'message'			=>		[ @SN_ATTR, 'xlink:href', 'level' ],
);

## XForms Event Elements
our %XFORMS_EVENT = (
	'activate'			=>	[],
	'alert'				=>	[],
	'blur'				=>	[],
	'delete'			=>	[],
	'deselect'			=>	[],
	'focus'				=>	[],
	'help'				=>	[],
	'hint'				=>	[],
	'initializeDone'	=>	[],
	'insert'			=>	[],
	'invalid'			=>	[],
	'modelConstruct'	=>	[],
	'modelInitialize'	=>	[],
	'next'				=>	[],
	'previous'			=>	[],
	'scrollFirst'		=>	[],
	'scrollLast'		=>	[],
	'select'			=>	[],
	'submit'			=>	[],
	'UIInitialize'		=>	[],
	'valid'				=>	[],
	'refresh'			=>	[],
	'recalculate'		=>	[],
	'reset'				=>	[],
	'revalidate'		=>	[],
	'valueChanging'		=>	[],
	'valueChanged'		=>	[],
);

## XForms Control Attribute Hash
our %XFORMS_CONTROL = (
	'button'		=>	[ @CM_ATTR ],
	'choices'		=>	[],
	'input'			=>	[ @CM_ATTR, @SN_ATTR, 'inputMode' ],
	'item'			=>	[ 'id' ],
	'itemset'		=>	[ @NS_ATTR ],
	'output'		=>	[ @SN_ATTR ],
	'range'			=>	[ @CM_ATTR, @SN_ATTR, 'start', 'end', 'stepSize' ],
	'secret'		=>	[ @CM_ATTR, @SN_ATTR, 'inputMode' ],
	'selectMany'	=>	[ @CM_ATTR, @SN_ATTR, 'selectUI' ],
	'selectOne'		=>	[ @CM_ATTR, @SN_ATTR, 'selectUI', 'selection' ],
	'submit'		=>	[ @CM_ATTR, 'submitInfo' ],
	'textarea'		=>	[ @CM_ATTR, @SN_ATTR, 'inputMode' ],
	'upload'		=>	[ @CM_ATTR, @SN_ATTR, 'mediaType' ],
	'value'			=>	[ @SN_ATTR ],  
);

## XForms Control Common Child Elements
our %XFORMS_CONTROL_CHILDREN = (
	'action'	=>  [],
	'actions'	=>  [],
	'alert'		=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'caption'	=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'extension'	=>	[],
	'help'		=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'hint'		=>	[ @CM_ATTR, @SN_ATTR, 'href' ], 
);

## XForms Model Elements with attributes.
our %XFORMS_MODEL_CHILDREN = (
	'action'		=>	[],
	'bind'			=>	[ 'ref', 'type', 'readOnly', 'required', 'relevant',
						  'isValid', 'calculate', 'maxOccurs', 'minOccurs' ],
	'extension'		=>	[],
	'instance'		=>	[ 'href' ],
	'schema'		=>	[ 'href' ],
	'submitInfo'	=>	[ @SN_ATTR, 'action', 'mediaTypeExtension', 'method',
						  'version', 'indent', 'encoding', 'mediaType', 
						  'omitXMLDeclaration', 'standalone', 
						  'CDATASectionElements', 'replace' ],
	'privacy'		=>	[ 'href' ],
);

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
		if( ( defined( $_ ) ) && ( $_ ne "" ) )
		{
			if( ( ref ) && ( $_->isa( "XML::LibXML::Node" ) ) )
			{
				$node->appendChild( $_ );
			}
			else
			{
				## If we get to this point assume we have appendable text.
				$node->appendText( $_ )
			}
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

 use XML::XForms::Generator::Common;

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
