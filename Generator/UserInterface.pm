package XML::XForms::Generator::UserInterface;
######################################################################
##                                                                  ##
##  Package:  UserInterface.pm                                      ##
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

our $VERSION = "0.5.0";

no strict "refs";

## Loop through each element in the CONTROLS_ATTR hash and generate a
## subroutine to match it.
foreach my $uiobject ( keys( %XFORMS_USER_INTERFACE ) )
{
	## Add the control name to be exported.
	Exporter::export_tags( "xforms_$uiobject" );
	
	## Create the closure ... add it to the symbol table
	*{ "xforms_$uiobject" } = sub {
		
		## Pull in the parameters.
		my $attributes = shift;
		my $uichildren = shift;
		my @children = @_;
		
		## Generate a the new control.
		my $self = XML::XForms::Generator::UserInterface->new( $uiobject );
		
		## Add the namespace to the node.
		$self->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
		
		## Append the appropriate attributes of the control.
		$self->_set_attributes( $attributes );

		## Append the the children of the control.
		$self->_append_children( $uichildren );
		
		## Stick any other data we have on the element.
		$self->_append_array_data( @children );

		return( $self );
	};
}

use strict "refs";

##==================================================================##
##  Constructor(s)/Deconstructor(s)                                 ##
##==================================================================##

##----------------------------------------------##
##  new                                         ##
##----------------------------------------------##
##  UserInterface default contstructor.         ##
##----------------------------------------------##
sub new
{
	## Pull in what type of an object we will be.
	my $type = shift;
	## Pull in the parameters ...
	my $uiobject = shift;
	## The object we are generating is going to be a child class of
	## XML::LibXML's DOM objects.
	my $self = XML::LibXML::Element->new( $uiobject );
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
##  UserInterface default deconstructor.        ##
##----------------------------------------------##
sub DESTROY
{
	## This is mainly a placeholder to keep things like mod_perl happy.
	return;
}

##==================================================================##
##  Method(s)                                                       ##
##==================================================================##

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

	## Right now only the group element has the capability of having a 
	## caption.  This subroutine at the momment could be considered 
	## overkill at the momment, but we use it to keep it easy to add
	## features later.
	if( $self->nodeName eq "group" )
	{
		if( defined( $$children{ 'caption' } ) )
		{
			my $node = XML::LibXML::Element->new( 'caption' );
	
			$node->appendText( $$children{ 'caption' } );

			$self->appendChild( $node );
			
			$node->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
		}
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
	
	foreach( @{ $XFORMS_USER_INTERFACE{ $self->nodeName } } )
	{
		## If the attribute is defined, then go ahead and work with it.
		if( defined( $$attributes{ $_ } ) )
		{
			## Attach the attribute to the control
			$self->setAttribute( $_, $$attributes{ $_ } );
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

XML::XForms::Generator::UserInterface

=head1 SYNOPSIS

 use XML::XForms::Generator;

 my $ui = xforms_group( { model => 'default' },
                        { caption => 'Address' },
                        @address_controls_and_markup );

=head1 DESCRIPTION

The XML::LibXML DOM wrapper provided by XML::XForms::Generator module
is based on convience functions for quick creation of XForms user 
interface elements.  These functions are named after the user interface
element they create prefixed by 'xforms_'.  The result of 'xforms_'
convience functions is an object with all of the methods available to
a standard XML::LibXML::Element along with all of the convience methods
listed further down in this document under the METHODS section.

=head1 METHODS

=over 4

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
 XML::XForms::Generator::Control
 XML::XForms::Generator::Model
 XML::LibXML
 XML::LibXML::DOM

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
