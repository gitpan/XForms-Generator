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
use XML::XForms::Generator::Common;

our @ISA = qw( Exporter XML::LibXML::Element );

$XML::XForms::Generator::Control::VERSION = "0.4.0";

no strict "refs";

## Loop through each element in the CONTROLS_ATTR hash and generate a
## subroutine to match it.
foreach my $control ( keys( %XFORMS_CONTROL ) )
{
	## Add the control name to be exported.
	Exporter::export_tags( "xforms_$control" );
	
	## Create the closure ... add it to the symbol table
	*{ "xforms_$control" } = sub {
		
		## Pull in the parameters.
		my %params = @_;
		
		## Generate a the new control.
		my $self = XML::XForms::Generator::Control->new( __type__ => $control );
		
		## Append the appropriate attributes of the control.
		$self->_set_attributes( \%params );

		## Append the the children of the control.
		$self->_append_children( \%params );
		
		## Finally make it namespace happy.
		$self->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
		
		return( $self );
	};
}

## Loop through each of the potential children of a control and generate
## a set and get function for each.
foreach my $child ( keys( %XFORMS_CONTROL_CHILDREN ) )
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
				foreach( @{ $XFORMS_CONTROL_CHILDREN{ $child } } )
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
##  _append_children                            ##
##----------------------------------------------##
##  Convience function in which one can set     ##
##  common children quickly.                    ##
##----------------------------------------------##
sub _append_children
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
##  _set_attributes                             ##
##----------------------------------------------##
##  Convience function in which you can set     ##
##  name/value attribute pairs quickly.         ##
##----------------------------------------------##
sub _set_attributes
{
	my( $self, $attributes ) = @_;

	my $control = $self->nodeName;
	
	foreach( @{ $XFORMS_CONTROL{ "xforms_$control" } } )
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
##  _set_control_element_attributes             ##
##----------------------------------------------##
##  Convience function to set attributes of     ##
##  control elements.                           ##
##----------------------------------------------##
sub _set_control_element_attributes
{
	my( $node, $attributes ) = @_;

	my $name = $node->nodeName;
	
	foreach( @{ $XFORMS_CONTROL_CHILDREN{ $name } } )
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

=head1 SYNOPSIS

 use XML::XForms::Generator;

 my $control = xforms_input( { class => 'someclass' },
                             caption => 'Username:',	
                             help    => 'Enter your username!' );

 $control->setInstanceData( $model, '/username', 'dhageman' );

=head1 DESCRIPTION

The XML::LibXML DOM wrapper the XML::XForms::Generator module provides is
based on convience functions for quick creation of XForms controls.  These
functions are named after the XForms control they create prefixed by 
'xforms_'.  The result of 'xforms_' convience functions is an object
with all of the methods available to a standard XML::LibXML::Element
along with all of the convience methods listed further down in this 
documentation under the METHODS section.

Each XForms control function takes a hash reference to set of name => value
pairs that describe the control's attributes and set of name => value
pairs that are associated with a controls child elements.

=head1 XFORMS CONTROLS

 button     - Generates a button
 choices    - optgroup replacement
 input      - Simple text entry box
 item       - Wrapper for a value and caption
 itemset    - Collection of items
 output     - Display instance data
 range      - Selection of a set of contiguous data
 secret     - "Password" entry box
 selectMany - Multi-selection box
 selectOne  - Selection box
 submit     - Submit button
 textarea   - Large text entry box
 upload     - Control for file uploads
 value      - Data part of an item

=head1 METHODS

=over 4 

=item setAction ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the alert child of a control.  
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setActions ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the alert child of a control.  
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setAlert ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the alert child of a control.  
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setCaption ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the caption child of a control.
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setExtension ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the extension child of a control.
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setHelp ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the help child of a control.
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setHint ( { ATTRIBUTES }, @CHILDREN )

Convience method to set the hint child of a control.
This method takes a reference to a hash of name => value pairings for the attributes and an array of XML::LibXML enable DOM data or text.  Please note that if an attribute is given that is not part of the XForms specification that it will be ignored.

=item setInstanceData ( MODEL, BIND_REF, @DATA )

This method takes a XML::XForms::Generator::Model object as its first
argument, a very very basic XPath statement for the instance data location
and finally it takes an array of XML::LibXML capable nodes and/or text.

=back

=head1 AUTHOR

D. Hageman E<lt>dhageman@dracken.comE<gt>

=head1 SEE ALSO

 XML::XForms::Generator
 XML::XForms::Generator::Action
 XML::XForms::Generator::Model
 XML::LibXML
 XML::LibXML::DOM

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2000-2001 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
