<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xf="http://www.w3.org/2002/01/xforms" 
  xmlns:dyn="http://icl.com/saxon"
  xmlns:str="http://exslt.org/strings"
  xmlns:func="http://exslt.org/functions"
  xmlns:local="urn:local"
  extension-element-prefixes="dyn str func"
  >
<!-- note: when exslt upgrade, can replate saxon w/
     xmlns:dyn="http://exslt.org/dynamic" 
     -->

<xsl:output method='html' 
  doctype-public='-//W3C//DTD HTML 4.01//EN'
  omit-xml-declaration='yes'/>

<xsl:strip-space elements='*'/>

<xsl:param name="list-size" select='5'/>
<xsl:param name='textarea-rows' select='5'/>
<xsl:param name='textarea-cols' select='20'/>

<xsl:variable name='urlencoding' select='"application/x-www-urlencoded"'/>

<xsl:template match='xf:caption|xf:hint|xf:model'/>

<!-- the version id -->
<xsl:template match='/'>
  <xsl:comment>
    Form Generated by:
      $Id: xforms.xsl,v 1.5 2002/08/08 23:17:02 rick Exp $
  </xsl:comment>
  <xsl:text>
  </xsl:text>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<!-- html/non-xforms text nodes -->
<xsl:template match='*'>
  <xsl:copy>
    <xsl:apply-templates select='@*'/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!-- and their attributes -->
<xsl:template match='@*'>
  <xsl:copy/>
</xsl:template>

<!-- the meat of the matter, outermost groups -->
<xsl:template match='xf:group[not(ancestor::xf:group)]'>
  <form>
    <xsl:for-each select='local:get-model()'>
      <xsl:attribute name='action'>
        <xsl:value-of select='xf:submitInfo/@action'/>
      </xsl:attribute>
      <xsl:attribute name='method'>
        <xsl:value-of select='xf:submitInfo/@method'/>
      </xsl:attribute>
      <xsl:attribute name='id'>
        <xsl:choose>
          <xsl:when test='@id'>
            <xsl:value-of select='@id'/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:for-each>
      <xsl:attribute name='enctype'>
        <xsl:value-of select='local:get-encoding()'/>
      </xsl:attribute>
    <xsl:apply-templates/>
  </form>
</xsl:template>

<!-- CONTROLS -->

<!-- xf:input -->
<xsl:template match="xf:input">
  <xsl:call-template name='input'>
    <xsl:with-param name='type' select='"text"'/>
  </xsl:call-template>
</xsl:template>

<!-- xf:secret -->
<xsl:template match="xf:secret">
  <xsl:call-template name='input'>
    <xsl:with-param name='type' select='"password"'/>
  </xsl:call-template>
</xsl:template>

<xsl:template match='xf:textarea'>
  <div class='input'>
    <xsl:call-template name='caption'/>
    <span class='input'>
      <textarea rows='{$textarea-rows}' cols='{$textarea-cols}'>
        <xsl:call-template name='get-name-attribute'/>
        <xsl:call-template name='common-attributes'/>
        <xsl:value-of select='local:get-instance-data(true())'/>
      </textarea>
    </span>
  </div>
</xsl:template>

<xsl:template match='xf:output'>
  <span class='output'>
    <xsl:value-of select='local:get-instance-data()'/>
  </span>
</xsl:template>

<xsl:template match='xf:upload'>
  <div class='input'>
    <xsl:call-template name='hint'/>
    <xsl:call-template name='caption'/>
    <span class='input'>
    <input type='file' accept='{@media-type}'
      value='{local:get-instance-data()}'>
      <xsl:call-template name='get-name-attribute'/>
      <xsl:call-template name='common-attributes'/>
    </input>
  </span>
  </div>
</xsl:template>

<xsl:template match='xf:range'/>

<!-- xf: button -->
<xsl:template match="xf:button">
  <button>
    <xsl:call-template name='get-name-attribute'/>
    <xsl:if test='@class'>
      <xsl:attribute name='class'>
        <xsl:value-of select='@class'/>
      </xsl:attribute>
    </xsl:if>
    <xsl:value-of select='normalize-space(xf:caption)'/>
  </button>
</xsl:template>

<xsl:template match='xf:submit'>
  <input type='submit'>
    <xsl:call-template name='hint'/>
    <xsl:call-template name='common-attributes'/>
    <xsl:attribute name='value'>
      <xsl:call-template name='caption-text'/>
    </xsl:attribute>
  </input>
</xsl:template>

<xsl:template match='xf:selectOne|xf:selectMany'>
  <!-- open selection not supported -->
  <xsl:param name='type' select='@selectUI'/>
  <xsl:variable name='data' 
    select='local:get-instance-data()'/>
  <div class='input'>
    <xsl:call-template name='hint'/>
    <xsl:call-template name='caption'/>
    <span class='input'>
      <xsl:choose>
        <xsl:when test='$type = "radio" or $type="checkbox"'>
          <xsl:call-template name='input-list'>
            <xsl:with-param name='type' select='$type'/>
            <xsl:with-param name='data' select='$data'/>
            <xsl:with-param name='name' select='local:get-path(false())'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name='select-list'>
            <xsl:with-param name='type' select='$type'/>
            <xsl:with-param name='data' select='$data'/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </span>
</div>
</xsl:template>

<xsl:template name='input-list'>
  <xsl:param name='type'/>
  <xsl:param name='data'/>
  <xsl:param name='name'/>
  <!-- ignores choices -->
  <xsl:for-each select='xf:item'>
    <xsl:variable name='value' select='xf:value'/>
    <input type='{$type}' value='{$value}' name='{$name}'>
      <xsl:for-each  select='str:tokenize($data)'>
        <xsl:if test='$value = .'>
          <xsl:attribute name='checked'>checked</xsl:attribute>
        </xsl:if>
      </xsl:for-each>
    </input>
    <xsl:value-of select='xf:caption'/>
  </xsl:for-each>
</xsl:template>


<xsl:template name='select-list'>
  <xsl:param name='type'/>
  <xsl:param name='data'/>
  <select>
    <xsl:call-template name='get-name-attribute'/>
    <xsl:if test='local-name()="selectMany"'>
      <xsl:attribute name='multiple'>
        <xsl:text>multiple</xsl:text>
      </xsl:attribute>
    </xsl:if>
    <xsl:attribute name='size'>
      <xsl:choose>
        <xsl:when test='$type="menu"'>1</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='$list-size'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates>
      <xsl:with-param name='data' select='$data'/>
    </xsl:apply-templates>
  </select>
</xsl:template>

<xsl:template match='xf:choices'>
  <optgroup>
    <xsl:attribute name='label'>
      <xsl:call-template name='caption-text'/>
    </xsl:attribute>
    <xsl:call-template name='hint'/>
    <xsl:apply-templates>
      <xsl:with-param name='data' select='$data'/>
    </xsl:apply-templates>
  </optgroup>
</xsl:template>

<xsl:template name='_item'>
  <xsl:param name='value'/>
  <xsl:param name='caption'/>
  <xsl:param name='data'/>
  <option value='{$value}'>
    <xsl:for-each select='str:tokenize($data)'>
      <xsl:if test='$value = .'>
        <xsl:attribute name='selected'>selected</xsl:attribute>
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select='$caption'/>
  </option>
</xsl:template>

<xsl:template match='xf:item'>
  <xsl:param name='data'/>
  <xsl:call-template name='_item'>
    <xsl:with-param name='value' select='xf:value'/>
    <xsl:with-param name='caption' select='xf:caption'/>
    <xsl:with-param name='data' select='$data'/>
  </xsl:call-template>
</xsl:template>

<xsl:template match='xf:itemset'>
  <xsl:param name='data'/>
  <xsl:variable name='caption' select='xf:caption/@ref'/>
  <xsl:variable name='value' select='xf:value/@ref'/>
  <xsl:variable name='path' select='local:get-path(true(),true())'/>
  <xsl:for-each select='local:get-model()'>
    <xsl:for-each select='dyn:evaluate($path)'>
      <xsl:call-template name='_item'>
        <xsl:with-param name='value' select='dyn:evaluate($value)'/>
        <xsl:with-param name='caption' select='dyn:evaluate($caption)'/>
        <xsl:with-param name='data' select='$data'/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template match='xf:group'>
  <xsl:choose>
    <xsl:when test='@class="no-display"'>
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:call-template name='common-attributes'/>
        <xsl:call-template name='hint'/>
        <span class='group-caption'>
          <xsl:call-template name='caption-text'/>
        </span>
        <xsl:apply-templates/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- functions and utility (called) templates -->
<func:function name="local:get-instance-data">
  <xsl:param name='no-normalize'/>
  <xsl:variable name='path'>
    <xsl:value-of select='local:get-path()'/>
    <xsl:value-of select='"[1]"'/>
  </xsl:variable>
  <func:result>
    <xsl:if test='$path !="[1]"'>
      <xsl:for-each select='local:get-model()'>
        <xsl:variable name='data'>
          <xsl:value-of select='dyn:evaluate($path)'/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test='$no-normalize'>
            <xsl:value-of select='$data'/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select='normalize-space($data)'/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </func:result>
</func:function>

<func:function name='local:get-model'>
  <!-- Question: unclear in the spec: do child elements
       inherit their parents model?? For now, assume yes -->
  <xsl:param name='model' select='ancestor-or-self::xf:*/@model'/>
  <xsl:choose>
    <xsl:when  test='$model'>
      <func:result select='//xf:model[@id=$model]'/>
    </xsl:when>
    <xsl:otherwise>
      <func:result select='//xf:model[1]'/>
    </xsl:otherwise>
  </xsl:choose>
</func:function>

<func:function name='local:get-path'>
  <xsl:param name='full-path' select='true()'/>
  <xsl:param name='use-nodeset'/>
  <xsl:variable name='path'>
    <xsl:choose>
      <xsl:when test='@bind'>
        <xsl:variable name='id' select='@bind'/>
        <xsl:for-each select='local:get-model()'>
          <xsl:for-each select='descendant::xf:bind[@id=$id]'>
            <xsl:value-of select='local:_get-path($full-path)'/>
            <xsl:choose>
              <xsl:when test='$use-nodeset'>
                <xsl:value-of select='@nodeset'/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select='@ref'/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test='@ref'>
        <xsl:value-of select='local:_get-path($full-path)'/>
        <xsl:value-of select='@ref'/>
      </xsl:when>
      <xsl:when test='@nodeset'>
        <xsl:if test='$full-path'>
          <xsl:value-of select='"xf:instance/"'/>
        </xsl:if>
        <xsl:value-of select='@nodeset'/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <func:result>
    <xsl:choose>
    <xsl:when test='local:get-encoding() = $urlencoding and not($full-path)'>
      <xsl:call-template name='basename'>
        <xsl:with-param name='path' select='$path'/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select='$path'/>
    </xsl:otherwise>
  </xsl:choose>
  </func:result>
</func:function>

<xsl:template name='basename'>
  <xsl:param name='path'/>
  <xsl:choose>
    <xsl:when test='contains($path,"/")'>
      <xsl:call-template name='basename'>
        <xsl:with-param name='path' select='substring-after($path,"/")'/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select='$path'/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<func:function name='local:_get-path'>
  <xsl:param name='full-path'/>
  <func:result>
    <xsl:if test='$full-path'>
      <xsl:value-of select='"xf:instance/"'/>
    </xsl:if>
    <xsl:for-each select='ancestor::*[@ref]'>
      <xsl:value-of select='@ref'/>
      <xsl:text>/</xsl:text>
    </xsl:for-each>
  </func:result>
</func:function>

<func:function name='local:get-encoding'>
  <func:result>
    <xsl:for-each select='local:get-model()'>
      <xsl:choose>
        <xsl:when test='xf:submitInfo/@encoding'>
          <xsl:value-of select='xf:submitInfo/@encoding'/>
        </xsl:when>
        <xsl:otherwise>multipart/form-data</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </func:result>
</func:function>

<xsl:template name='get-name-attribute'>
  <xsl:attribute name='name'>
    <xsl:value-of select='local:get-path(false())'/>
  </xsl:attribute>
</xsl:template>

<xsl:template name='common-attributes'>
  <xsl:if test='@class'>
    <xsl:attribute name='class'>
      <xsl:value-of select='@class'/>
    </xsl:attribute>
  </xsl:if>
  <xsl:if test='@accessKey'>
    <xsl:attribute name='accesskey'>
      <xsl:value-of select='@accessKey'/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>

<xsl:template name='caption-text'>
  <xsl:for-each select='./xf:caption'>
    <xsl:variable name='data' select='local:get-instance-data()'/>
    <xsl:choose>
      <xsl:when test='$data !=""'>
        <xsl:value-of select='$data'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='normalize-space(.)'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template name='caption'>
  <span class='caption'>
    <xsl:call-template name='caption-text'/>
  </span>
</xsl:template>

<xsl:template name='hint'>
  <xsl:attribute name='title'>
    <xsl:value-of select='normalize-space(xf:hint)'/>
  </xsl:attribute>
</xsl:template>

<xsl:template name='input'>
  <xsl:param name='type'/>
  <div class='input'>
    <xsl:call-template name='hint'/>
    <xsl:call-template name='caption'/>
    <span class='input'>
      <input value='{local:get-instance-data()}'>
        <xsl:call-template name='get-name-attribute'/>
        <xsl:attribute name='type'>
          <xsl:value-of select='$type'/>
        </xsl:attribute>
        <xsl:call-template name='common-attributes'/>
      </input>
    </span>
  </div>
  <xsl:text>
  </xsl:text>
</xsl:template>

</xsl:stylesheet>