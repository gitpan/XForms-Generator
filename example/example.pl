#!/usr/bin/perl

use XML::LibXML;
use XML::XForms::Generator;

{
	## Generate a model element.
	my $model = xforms_model( id => 'myForm' );

	## We need to really set a submit info.  It don't really work without one.
	## The thing about the model is that it doesn't totally make it dummy 
	## proof.  A person still needs to understand the standard to make it 
	## work.  The goal of this module is to reduce the typing to get from
	## point 'A' to 'B'.
	$model->setSubmitInfo( { action => 'http://www.test.com/cgi-bin/test.cgi',
							 method => 'POST' } );

	## Generate a button element.
	my $button_control = xforms_button( class => 'button',
										help  => 'Click the button!' );

	## I think I will put a caption on there as well ...
	$button_control->setCaption( {}, 'This is a button!' );
	
	## Oops, didn't like the original help!
	$button_control->setHelp( {}, 'Click the pretty button!' );

	## These two lines are equivalent to the the above line.
	my $element = XML::LibXML::Text->new( "Click on the pretty button!" );
	$button_control->setHelp( {}, $element );

	## Set some instance data ... it will automagically generate the
	## XPath for you, but it doesn't understand much more then a
	## XPath that is made of /*/*/ chunks (at least at the momment).
	## Again, it isn't dummy proof ... you can ruin things if you
	## don't know what you are doing.
	$button_control->setInstanceData( $model, '//button', 'Huh?' );

	## These elements inherit all the love of XML::LibXML ... so you can
	## do stuff like:
	print $model->toString( 2 ) . "\n";
	print $button_control->toString( 2 )  . "\n";


	exit( 0 );
}
