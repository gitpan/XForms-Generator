use ExtUtils::MakeMaker;

print "                                                       \n";
print "                                                       \n";
print "**WARNING**  Notice of a major code change! **WARNING**\n";
print "-------------------------------------------------------\n";
print "Major changes to this module have occured to this perl \n";
print "module since the last release due to a new version of  \n";
print "the XForms Specification (Candidate Recommendation)!   \n";
print "Your old code will break because of this!  Read the    \n";
print "documentation for an understanding of the changes!     \n";
print "                                                       \n";
print "                                                       \n";

sleep( 5 );

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'			=> 'XML::XForms::Generator',
    'AUTHOR'     	=> 'D. Hageman <dhageman@dracken.com>',
    'ABSTRACT' 		=> 'Library for generating W3\'s XForms document elements.',
    'VERSION_FROM'	=> 'Generator.pm',
    'PREREQ_PM'		=> { 'XML::LibXML'			=>	'1.52',
						 'Exporter::Cluster'	=>	0		} 
);
