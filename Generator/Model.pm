package XML::XForms::Generator::Model;
######################################################################
##                                                                  ##
##  Package:  Model.pm                                              ##
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

our $VERSION = "0.2.0";

our @EXPORT = qw( xforms_model );

our $XFORMS_NSURI = "http://www.w3.org/2002/01/xforms";
our $XFORMS_NSPREFIX = "xforms";

## XForms Single Node Binding Attributes
our @SN_ATTR = qw( ref model bind );
## XForms Nodeset Binding Attributes
our @NS_ATTR = qw( nodeset model bind );

## XForms Model Elements with attributes.
our %MODEL_ELEMENT = (
	'instance'		=>	[ 'href' ],
	'schema'		=>	[ 'href' ],
	'privacy'		=>	[ 'href' ],
	'submitInfo'	=>	[ @SN_ATTR, 'action', 'mediaTypeExtension', 'method',
						  'version', 'indent', 'encoding', 'mediaType', 
						  'omitXMLDeclaration', 'standalone', 
						  'CDATASectionElements', 'replace' ],
	'bind'			=>	[ 'ref', 'type', 'readOnly', 'required', 'relevant',
						  'isValid', 'calculate', 'maxOccurs', 'minOccurs' ],
	'action'		=>	[],
	'extension'		=>	[]
);

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
	'message'			=>		[ @SN_ATTR, 'xlink:href', 'level' ]
);

## Loop through the model elements and build convience functions for them.
foreach my $element ( keys( %MODEL_ELEMENT ) )
{
	no strict "refs";
	
	## Create the closure ... add it to the symbol table.
	*{ "set" . ucfirst( $element ) } = sub {

		my( $self, $attribute, @data ) = @_;

		## Determine of the node already exists or not.
		my( $node ) = $self->getChildrenByTagName( $element );

		## If the node is not defined, we need to create it and attach it.
		if( !defined( $node ) )
		{
			$node = XML::LibXML::Element->new( $element );
			$node->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
			$self->appendChild( $node );
		}

		## Loop through each of the valid attributes.
		foreach( @{ $MODEL_ELEMENT{ $element } } )
		{
			if( defined( $$attribute{ $_ } ) )
			{
				## Set the attribute of the node.
				$node->setAttribute( $_, $$attribute{ $_ } );
			}
		}
		
		## Stick the data onto the node.
		_append_array_data( $node, @data );
	
		return( $node );
	};

	## Function to get a child element node.
	*{ "get" . ucfirst( $element ) } = sub {
		
		my $self = shift;

		my( $node ) = $self->getChildrenByTagName( $element );

		return( $node );
	};
	
	use strict "refs";
}
				
##==================================================================##
##  Constructor(s)/Deconstructor(s)                                 ##
##==================================================================##

##----------------------------------------------##
##  new                                         ##
##----------------------------------------------##
##  XForms::Model default contstructor.         ##
##----------------------------------------------##
sub new
{
	## Pull in what type of an object we will be.
	my $type = shift;
	## Pull in any arguments provided to the constructor.
	my %params = @_;
	## The object we are generating is going to be a child class of
	## XML::LibXML's DOM objects.
	my $self = XML::LibXML::Element->new( 'model' );
	## Determine what exact class we will be blessing this instance into.
	my $class = ref( $type ) || $type;
	## Bless the class for it is good [tm].
	bless( $self, $class );
	## We need to set our namespace on our model element and activate it.
	$self->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
	## Determine if we have an 'id' attribute and set it if we do.
	if( defined( $params{ 'id' } ) )
	{
		$self->setAttribute( "id", $params{ 'id' } );
	}
	## Send it back to the caller all happy like.
	return( $self );
}

##----------------------------------------------##
##  DESTROY                                     ##
##----------------------------------------------##
##  XForms::Model default deconstructor.        ##
##----------------------------------------------##
sub DESTROY
{
	## This is mainly a placeholder to keep things like mod_perl happy.
	return;
}

##==================================================================##
##  Method(s)                                                       ##
##==================================================================##

##----------------------------------------------##
##  setInstanceData                             ##
##----------------------------------------------##
##  Method for assisting in the creation of     ##
##  instance data that is not necessarily       ##
##  associated with a control.                  ##
##----------------------------------------------##
sub setInstanceData
{
	my( $self, $ref, @data ) = @_;

	my $instance = $self->getInstance();

	## If an instance hasn't already been created, the above call
	## will return an undefined into $instane.  We need to ensure that
	## it is valid.
	if( !defined( $instance ) )
	{
		$instance = $self->setInstance();
	}

	## We need to build our instance data path if it doesn't
	## already exist.
	my $node = _ensure_xpath( $instance, $ref );

	## Stick the data onto that node.
	_append_array_data( $node, @data );

	return;
}

##==================================================================##
##  Function(s)                                                     ##
##==================================================================##

##----------------------------------------------##
##  xforms_model                                ##
##----------------------------------------------##
##  Alias for the default constructor.          ##
##----------------------------------------------##
sub xforms_model
{
	return( XML::XForms::Generator::Model->new( @_ ) );
}

##==================================================================##
##  Internal Function(s)                                            ##
##==================================================================##

##----------------------------------------------##
##  _append_array_data                          ##
##----------------------------------------------##
##  Convience function to analyze an array and  ##
##  append it appropriately.                    ##
##----------------------------------------------##
sub _append_array_data
{
	my $node = shift;

	## Loop through the data ...
	foreach( @_ )
	{
		## Look for elements that are attachable.
		if( $_->isa( "XML::LibXML::Node" ) )
		{
			$node->appendChild( $_ );
		}
		else
		{
			## We are going to assume this will be 'appendable' text.
			$node->appendText( $_ );
		}
	}

	return;
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

XML::XForms::Generator::Model

=head1 DESCRIPTION

XForms::Model is a DOM wrapper to ease the creation of XML that is complaint
with the schema of the W3's XForms specification.

The XForms webpage is located at: http://www.w3.org/MarkUp/Forms/

=head1 METHODS

=over 4 

=item appendChildren

=item getAction

=item getBind

=item getInstance

=item getExtension

=item getPrivacy

=item getSchema

=item getSubmitInfo

=item setAttributes

=item setAction

=item setBind

=item setInstance

=item setExtension

=item setPrivacy

=item setSchema

=item setSubmitInfo

=back

=head1 FUNCTIONS

=over 4

=item xforms_model

=back

=head1 AUTHOR

D. Hageman E<lt>dhageman@dracken.comE<gt>

=head1 SEE ALSO

L<XML::LibXML>, L<XML::LibXML::DOM>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2000-2001 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
