package XML::XForms::Generator::Control;
######################################################################
##                                                                  ##
##  Package:  Control.pm                                            ##
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

our $XFORMS_NSURI = "http://www.w3.org/2002/01/xforms";
our $XFORMS_NSPREFIX = "xforms";

## XForms Common Attributes
our @CM_ATTR = qw( xml:lang class navIndex accessKey );
## XForms Single Node Binding Attributes
our @SN_ATTR = qw( ref model bind );
## XForms Nodeset Binding Attributes
our @NS_ATTR = qw( nodeset model bind );

## XForms Control Attribute Hash
our %XFORMS_CONTROL = (
	'xforms_button'		=>	[ @CM_ATTR ],
	'xforms_choices'	=>	[],
	'xforms_input'		=>	[ @CM_ATTR, @SN_ATTR, 'inputMode' ],
	'xforms_item'		=>	[ 'id' ],
	'xforms_itemset'	=>	[ @NS_ATTR ],
	'xforms_output'		=>	[ @SN_ATTR ],
	'xforms_range'		=>	[ @CM_ATTR, @SN_ATTR, 'start', 'end', 'stepSize' ],
	'xforms_secret'		=>	[ @CM_ATTR, @SN_ATTR, 'inputMode' ],
	'xforms_selectMany'	=>	[ @CM_ATTR, @SN_ATTR, 'selectUI' ],
	'xforms_selectOne'	=>	[ @CM_ATTR, @SN_ATTR, 'selectUI', 'selection' ],
	'xforms_submit'		=>	[ @CM_ATTR, 'submitInfo' ],
	'xforms_textarea'	=>	[ @CM_ATTR, @SN_ATTR, 'inputMode' ],
	'xforms_upload'		=>	[ @CM_ATTR, @SN_ATTR, 'mediaType' ],
	'xforms_value'		=>	[ @SN_ATTR ]  );

## XForms Common Child Elements
our %CONTROL_ELEMENT = (
	'caption'	=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'help'		=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'hint'		=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'alert'		=>	[ @CM_ATTR, @SN_ATTR, 'href' ],
	'extension'	=>	[] );

no strict "refs";

## Loop through each element in the CONTROLS_ATTR hash and generate a
## subroutine to match it.
foreach my $control ( keys( %XFORMS_CONTROL ) )
{
	## Add the control name to be exported.
	Exporter::export_tags( $control );
	
	## Create the closure ... add it to the symbol table
	*{ $control } = sub {

		## Clean up control to get the correct type.
		$control =~ s/^xforms_//g;
	
		## Pull in the parameters of the function.
		my %params = @_;
		
		## Generate a the new control.
		my $self = XML::XForms::Generator::Control->new( __type__ => $control );
		
		## Append the appropriate attributes of the control.
		$self->setAttributes( %params );

		## Append the the children of the control.
		$self->appendChildren( %params );
		
		## Finally make it namespace happy.
		$self->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
		
		return( $self );
	};
}

## Loop through each of the potential children of a control and generate
## a set and get function for each.
foreach my $child ( keys( %CONTROL_ELEMENT ) )
{
	## Generate a set function for the element.
	*{ "set" . ucfirst( $child ) } = sub {

		my( $self, $attribute, @data ) = @_;

		## Determine the name of the XForms control.
		my $control = $self->nodeName;

		## See if we can find the child element we are operating on ...
		my( $node ) = $self->getChildrenByTagName( $child );

		## If the node already exists, then grab all the children and delete
		## them.
		if( defined( $node ) )
		{
			## Look to see if we have any data in our @data array so we know
			## if we need to reap the children of the element.
			if( scalar( @data ) > 0 )
			{
				my( @children ) = $node->childNodes;

				foreach( @children )
				{
					$node->removeChild( $_ );
				}
			}

			if( scalar( keys( %{ $attribute } ) ) > 0 )
			{
				foreach( @{ $CONTROL_ELEMENT{ $child } } )
				{
					$node->removeAttribute( $_ );
				}
			}
		}
		else
		{
			## The node doesn't exist, so generate one.
			$node = XML::LibXML::Element->new( $child );

			## Attach it to our control.
			$self->appendChild( $node );
		}

		_append_array_data( $node, @data ) if ( scalar( @data ) > 0 );

		_set_control_element_attributes( $node, $attribute );
		
		return( $node );
	};
}

use strict "refs";

##==================================================================##
##  Constructor(s)/Deconstructor(s)                                 ##
##==================================================================##

##----------------------------------------------##
##  new                                         ##
##----------------------------------------------##
##  XForms::Control default contstructor.       ##
##----------------------------------------------##
sub new
{
	## Pull in what type of an object we will be.
	my $type = shift;
	## Pull in the parameters ...
	my %params = @_;
	## The object we are generating is going to be a child class of
	## XML::LibXML's DOM objects.
	my $self = XML::LibXML::Element->new( $params{__type__} );
	## We need to make sure type doesn't go past this point.
	delete( $params{__type__} );
	## Determine what exact class we will be blessing this instance into.
	my $class = ref( $type ) || $type;
	## Bless the class for it is good [tm].
	bless( $self, $class );
	## Send it back to the caller all happy like.
	return( $self );
}

##----------------------------------------------##
##  DESTROY                                     ##
##----------------------------------------------##
##  XForms::Control default deconstructor.      ##
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
##  appendChildren                              ##
##----------------------------------------------##
##  Convience function in which one can set     ##
##  common children quickly.                    ##
##----------------------------------------------##
sub appendChildren
{
	my( $self, $children ) = @_;

	## Loop through all the common children of controls and attach them
	## if they are available.
	foreach( qw( caption help hint alert action ) )
	{
		if( defined( $$children{ $_ } ) )
		{
			my $node = XML::LibXML::Element->new( $_ );
	
			$node->appendText( $$children{ $_ } );

			$self->appendChild( $node );

			delete( $$children{ $_ } );
		}
	}

	## Anything left over at this point we can only assume are
	## extension "children" nodes.
	while( my( $key, $value ) = each( %{ $children } ) )
	{
		## Look for the extension to see if it exists.
		my $extension = $self->getChildrenByTagName( 'extension' );
		
		$extension = $extension->shift();
		
		## If this is the first 'extension' element, the extension 
		## isn't defined yet and we need to do that.
		if( !defined( $extension ) )
		{
			## Generate the extension node.
			$extension = XML::LibXML::Element->new( "extension" );

			## Attach the node to the control.
			$self->appendChild( $extension );
		}
		
		my $node = XML::LibXML::Element->new( $key );

		$node->appendText( $value );
		
		$extension->appendChild( $node );
	}

	return;
}

##----------------------------------------------##
##  setAttributes                               ##
##----------------------------------------------##
##  Convience function in which you can set     ##
##  name/value attribute pairs quickly.         ##
##----------------------------------------------##
sub setAttributes
{
	my( $self, $attributes ) = @_;

	my $control = $self->nodeName;
	
	foreach( @{ $XFORMS_CONTROL{$control} } )
	{
		## If the attribute is defined, then go ahead and work with it.
		if( defined( $$attributes{ $_ } ) )
		{
			## Attach the attribute to the control
			$self->setAttribute( $_, $$attributes{ $_ } );
			## Delete it from the attribute listing.
			delete( $$attributes{ $_ } );
		}
	}
	
	return;	
}

##----------------------------------------------##
##  setInstanceData                             ##
##----------------------------------------------##
##  Method for assisting in the creation of     ##
##  of instance data.                           ##
##----------------------------------------------##
sub setInstanceData
{
	my( $self, $model, $ref, @data ) = @_;

	## Do some type checking on the $model element.
	if( ref( $model ) ne "XML::XForms::Generator::Model" )
	{
		croak( "Error: Not a valid model element!" );
	}

	my $instance = $model->getInstance();
	
	## If an instance hasn't already been created, the above call
	## will return an undefined into $instane.  We need to ensure that
	## it is valid.
	if( !defined( $instance ) )
	{
		$instance = $model->setInstance();
	}

	my $node = _ensure_xpath( $instance, $ref );
	
	_append_array_data( $node, @data );
	
	$self->setAttribute( "ref", $ref );
	
	return;
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

	## Clean up the xpath a bit.
	$xpath =~ s/^\/\///g;
	
	## Break up the XPath statement into chunks.
	my @path = split( /\//, $xpath );

	## Loop through our path building our search pattern
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

##----------------------------------------------##
##  _set_control_element_attributes             ##
##----------------------------------------------##
##  Convience function to set attributes of     ##
##  control elements.                           ##
##----------------------------------------------##
sub _set_control_element_attributes
{
	my( $node, $attributes ) = @_;

	my $name = $node->nodeName;
	
	foreach( @{ $CONTROL_ELEMENT{ $name } } )
	{
		## If the attribute is defined, then go ahead and work with it.
		if( defined( $$attributes{ $_ } ) )
		{
			## Attach the attribute to the control
			$node->setAttribute( $_, $$attributes{ $_ } );
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

XML::XForms::Generator::Control

=head1 DESCRIPTION

XForms::Control is a DOM wrapper to ease the creation of XML that is complaint
with the schema of the W3's XForms specification.

The XForms webpage is located at: http://www.w3.org/MarkUp/Forms/

=head1 METHODS

=over 4 

=item appendChildren

=item setAttributes

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
