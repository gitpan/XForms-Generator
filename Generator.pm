package XML::XForms::Generator;
######################################################################
##                                                                  ##
##  Package:  Generator.pm                                          ##
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
require Exporter::Cluster;

use strict;
use warnings;

our @ISA = qw( Exporter::Cluster );

our %EXPORT_CLUSTER = ( 'XML::XForms::Generator::Model'		=>	[],
						'XML::XForms::Generator::Control'	=>	[] );

$XML::XForms::Generator::VERSION = "0.3.0";

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
##  End of Code                                                     ##
##==================================================================##
1;

##==================================================================##
##  Plain Old Documentation (POD)                                   ##
##==================================================================##

__END__

=head1 NAME

XML::XForms::Generator

=head1 DESCRIPTION

XForms is a XML::LibXML DOM wrapper to ease the creation of XML that is 
complaint with the schema of the W3's XForms last call working draft 
specification.

The XForms webpage is located at: http://www.w3.org/MarkUp/Forms/

=head1 AUTHOR

D. Hageman E<lt>dhageman@dracken.comE<gt>

=head1 SEE ALSO

 XML::XForms::Generator::Control
 XML::XForms::Generator::Model
 XML::LibXML
 XML::LibXML::DOM

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2000-2001 D. Hageman (Dracken Technologies).
All rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself. 

=cut
