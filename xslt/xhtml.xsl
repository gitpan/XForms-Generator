<!-- ==================================================================== -->
<!-- Name: XForms XLST conversion to HTML Forms                           -->
<!-- Author: D. Hageman <dhageman@dracken.com>                            -->
<!-- Copyright and License: Same terms as XML::XForms::Generator.         -->
<!-- ==================================================================== -->
<xsl:stylesheet version="1.0"
                xmlns:dyn="http://exslt.org/dynamic"
				xmlns:str="http://exslt.org/strings"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xforms="http://www.w3.org/2002/01/xforms" 
                extension-element-prefixes="dyn str">

<!-- Output Method -->
<xsl:output method="html" 
			indent="yes"
            omit-xml-delartaion="yes"
            doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN" />

<!-- ******************************************************************** -->
<!-- *************************** Functions ****************************** -->
<!-- ******************************************************************** -->

<xsl:template name="getInstanceData">
	<xsl:param name="ref"/>

	<xsl:variable name="suffix">
		<xsl:text>']</xsl:text>
	</xsl:variable>

	<xsl:variable name="prefix">
		<xsl:text>/*[local-name()='</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="xpath">
 		<xsl:for-each select="str:tokenize( $ref, '/' )">
			<xsl:variable name="loop">	
				<xsl:value-of select="."/>
			</xsl:variable>
			<xsl:value-of select="concat( $prefix, $loop, $suffix )"/>
		</xsl:for-each>
	</xsl:variable>

	<xsl:value-of 
		 select="dyn:evaluate( concat( '//xforms:instance', $xpath ) )"/>

</xsl:template>

<!-- ******************************************************************** -->
<!-- ***************************  Controls ****************************** -->
<!-- ******************************************************************** -->

<!-- xforms: button -->
<xsl:template match="xforms:button">
	<input type="button">
		<xsl:attribute name="value">
			<xsl:call-template name="getInstanceData">  
				<xsl:with-param name="ref" select="@ref"/> 
			</xsl:call-template>  
		</xsl:attribute>
	</input>
</xsl:template>

<!-- xforms:choices -->
<xsl:template match="xforms:choices">
	<optgroup>
		<xsl:apply-templates select="item"/>
	</optgroup>
</xsl:template>

<!-- xforms:input -->
<xsl:template match="xforms:input">
	<input type="text">
		<xsl:if test="@class">
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="value">
			<xsl:call-template name="getInstanceData">  
				<xsl:with-param name="ref" select="@ref"/> 
			</xsl:call-template>  
		</xsl:attribute>
	</input>
</xsl:template>

<!-- xforms:item -->
<xsl:template match="xforms:item">
	<option name="" value="">
		<xsl:attribute name="name">
			<xsl:value-of select="caption"/>
		</xsl:attribute>
		<xsl:attribute name="value">
			<xsl:value-of select="value"/>
		</xsl:attribute>
	</option>
</xsl:template>

<!-- xforms:itemset -->
<xsl:template match="xforms:itemset">
	<!-- I am going to avoid implementing this now like the plague. -->
</xsl:template>

<!-- xforms:model -->
<xsl:template match="xforms:model">
	<!-- We won't do anything for the model element. -->
</xsl:template>

<!-- xforms:output -->
<xsl:template match="xforms:output">
	<span>
	<xsl:if test="@class">
		<xsl:attribute name="class">
			<xsl:value-of select="@class"/>
		</xsl:attribute>
	</xsl:if>
	<xsl:call-template name="getInstanceData">  
		<xsl:with-param name="ref" select="@ref"/> 
	</xsl:call-template>
	</span>
</xsl:template>

<!-- xforms:range -->
<xsl:template match="xforms:range">
	<!-- I am avoiding implementing this like the plague! -->
</xsl:template>

<!-- xforms:secret -->
<xsl:template match="xforms:secret">
	<input type="password">
		<xsl:if test="@class">
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="value">
			<xsl:call-template name="getInstanceData">  
				<xsl:with-param name="ref" select="@ref"/> 
			</xsl:call-template>  
		</xsl:attribute>
	</input>
</xsl:template>

<!-- xforms:selectMany -->
<xsl:template match="xforms:selectMany">
	<select multiple="multiple">
		<xsl:apply-templates select="item"/>
	</select>
</xsl:template>

<!-- xforms:selectOne -->
<xsl:template match="xforms:selectOne">
	<select>
		<xsl:apply-templates select="item"/>
	</select>
</xsl:template>

<!-- xforms:submit -->
<xsl:template match="xforms:submit">
	<input type="submit" value="submit"/>
</xsl:template>

<!-- xforms:textbox -->
<xsl:template match="xforms:textbox">
	<textarea>
		<xsl:if test="@class">
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="getInstanceData">  
			<xsl:with-param name="ref" select="@ref"/> 
		</xsl:call-template>  
	</textarea>
</xsl:template>

<!-- xforms:upload -->
<xsl:template match="xforms:upload">
	<input type="upload">
		<xsl:if test="@class">
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="value">
			<xsl:call-template name="getInstanceData">  
				<xsl:with-param name="ref" select="@ref"/> 
			</xsl:call-template>  
		</xsl:attribute>
	</input>
</xsl:template>

<!-- xforms:value -->
<xsl:template match="xforms:value">
	<xsl:call-template name="getInstanceData">  
		<xsl:with-param name="ref" select="@ref"/> 
	</xsl:call-template>  
</xsl:template>

<!-- ******************************************************************** -->
<!-- ************************* Children ********************************* -->
<!-- ******************************************************************** -->

<xsl:template match="caption">
	<xsl:apply-templates/>
</xsl:template>

<!-- ******************************************************************** -->
<!-- *********************** User Interface ***************************** -->
<!-- ******************************************************************** -->

<xsl:template match="//xforms:group">
	<form method="" action="" encoding="">
		<!-- Determine the encoding based on the existance of an -->
		<!-- upload widget in the form -->
		<xsl:variable name="encoding">
			<xsl:choose>
				<xsl:when test="//*[xforms:upload]">
					<xsl:text>multipart/form-data</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>application/x-www-form-urlencoded</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:attribute name="action">
			<xsl:value-of 
				select="dyn:evaluate( '//xforms:submitInfo/@action' )"/>
		</xsl:attribute>
		<xsl:attribute name="method">
			<xsl:value-of 
				select="dyn:evaluate( '//xforms:submitInfo/@method' )"/>
		</xsl:attribute>
		<xsl:attribute name="encoding">
			<xsl:value-of select="$encoding"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</form>
</xsl:template>

<xsl:template match="xforms:group//xforms:group">
	<td>
	<xsl:apply-templates/>
	</td>
</xsl:template>

</xsl:stylesheet>
