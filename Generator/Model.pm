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
use XML::XForms::Generator::Common;

our @ISA = qw( Exporter XML::LibXML::Element );

our @EXPORT = qw( xforms_model );

our $VERSION = "0.5.1";

no strict "refs";

## Loop through the model elements and build convience functions for them.
foreach my $element ( keys( %XFORMS_MODEL_CHILDREN ) )
{
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
		foreach( @{ $XFORMS_MODEL_CHILDREN{ $element } } )
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
}

use strict "refs";
				
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

##
## None.
##

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

=head1 SYNOPSIS

 use XML::XForms::Generator;

 my $model = xforms_model( id => 'MyFirstXForms' );

=head1 DESCRIPTION

The XML::XForms::Generator::Model package is an implementation of the 
XForms model element.  This package has a single convience function 
(xforms_model) that takes a parameter 'id' to uniquely identify that model 
element in the document.  The result of calling this function is a
object that has all the methods available to a XML::LibXML::Element object
plus the methods listed below:

=head1 METHODS

=over 4 

=item getAction ()

Returns the action child of a model.

=item getBind ()

Returns the binding children of a model.

=item getInstance ()

Returns the instance data section associated with a model.

=item getExtension ()

Returns any extension children of a model.

=item getPrivacy ()

Returns the privary elements.

=item getSchema ()

Returns the schema child of a model.

=item getSubmitInfo ()

Returns the submitInfo data.

=item setAction ( { ATTRIBUTES }, @DATA )

Sets the action data of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=item setBind ( { ATTRIBUTES }, @DATA )

Sets the binding information of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=item setInstance ( { ATTRIBUTES }, @DATA )

Sets the instance data set of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=item setExtension ( { ATTRIBUTES }, @DATA )

Sets the extensions of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=item setPrivacy ( { ATTRIBUTES }, @DATA )

Sets the privacy methodology of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=item setSchema ( { ATTRIBUTES }, @DATA )

Sets the schema information of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=item setSubmitInfo ( { ATTRIBUTES }, @DATA )

Sets the submitInfo data of a model.
This method takes a hash refernce of name => value pairs for the attributes
of the model's child.  The attributes are attached on the basis of their
legitamacy when compared to the XForms schema.  If it isn't a recognized
attribute then it won't get attached.  This method also takes ana array
of XML::LibXML capable nodes and/or text data.

=back

=head1 AUTHOR

D. Hageman E<lt>dhageman@dracken.comE<gt>

=head1 SEE ALSO

 XML::XForms::Generator
 XML::XForms::Generator::Action
 XML::XForms::Generator::Control
 XML::XForms::Generator::UserInterface
 XML::LibXML
 XML::LibXML::DOM

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
