package XML::XForms::Generator::Action;
######################################################################
##                                                                  ##
##  Package:  Action.pm                                             ##
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

our $VERSION = "0.5.1";

no strict "refs";

## Loop through the model elements and build convience functions for them.
foreach my $action ( keys( %XFORMS_ACTION ) )
{
	## Add the name of the action to be exported.
	Exporter::export_tags( "xforms_action_" . $action );
	
	## Create the closure ... add it to the symbol table.
	*{ "xforms_action_" .  $action } = sub {

		## Pull in the parameters for the action.
		my %params = @_;

		my $self = XML::XForms::Generator::Action->new( __type__ => $action );

		## Append the appropriate attributes of the action.
		$self->_set_attributes( \%params );

		## Finally set the namespace on the action.
		$self->setNamespace( $XFORMS_NSURI, $XFORMS_NSPREFIX, 1 );
	
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
##  XForms::Action default contstructor.        ##
##----------------------------------------------##
sub new
{
	## Pull in what type of an object we will be.
	my $type = shift;
	## Pull in any arguments provided to the constructor.
	my %params = @_;
	## The object we are generating is going to be a child class of
	## XML::LibXML's DOM objects.
	my $self = XML::LibXML::Element->new( $params{__type__} );
	## We need to clean up the parameter ...
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
##  XForms::Action default deconstructor.       ##
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
##  Function(s)                                                     ##
##==================================================================##

##==================================================================##
##  Internal Function(s)                                            ##
##==================================================================##

##----------------------------------------------##
##  _set_attributes                             ##
##----------------------------------------------##
##  Convience function in which you can set     ##
##  name/value attribute pairs for an action    ##
##  quickly.                                    ##
##----------------------------------------------##
sub _set_attributes
{
	my( $self, $attributes ) = @_;

	foreach( @{ $XFORMS_ACTION{ $self->localname } }, "ev:event" )
	{
		## Events are special casses as we can do extra checking on them.
		if( ( $_ eq "ev:event" ) && ( defined( $$attributes{ "ev:event" } ) ) )
		{
			## Look to see if the event actually exists.
			if( exists( $XFORMS_EVENT{ $$attributes{ $_ } } ) )
			{
				## Attach the attribute like we normally do.
				$self->setAttribute( $_, $$attributes{ $_ } );
				## Delete it from the attribute listing.
				delete( $$attributes{ $_ } );
			}		
		}
		elsif( defined( $$attributes{ $_ } ) )
		{
			## Attach the attribute to the action node.
			$self->setAttribute( $_, $$attributes{ $_ } );
			## Delete it from the attribute listing.
			delete( $$attributes{ $_ } );
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

XML::XForms::Generator::Action

=head1 SYNOPSIS

 use XML::XForms::Generator::Action;

=head1 DESCRIPTION

The XML::XForms::Generator::Action package is an implementation of the 
action part of the XForms specification.

It is implemented with a set of convience functions that have the prefix
'xforms_action_' followed by the name of the action with the first letter
capitalized.

=head1 XFORMS ACTIONS

 dispatch        - 
 refresh         -
 recalculate     -
 setFocus        -
 loadURI         -
 setValue        -
 submitInstance  -
 resetInstance   -
 setRepeatCursor -
 insert          - 
 delete          -
 toggle          -
 script          -
 message         -

=head1 AUTHOR

D. Hageman E<lt>dhageman@dracken.comE<gt>

=head1 SEE ALSO

 XML::XForms::Generator
 XML::XForms::Generator::Control
 XML::XForms::Genertaor::Model
 XML::XForms::Genertaor::UserInterface
 XML::LibXML
 XML::LibXML::DOM

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
