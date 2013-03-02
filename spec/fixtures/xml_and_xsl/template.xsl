<?xml version="1.0" encoding="utf-8"?>
<t:stylesheet xmlns:t="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <t:template match="root">
    <t:text disable-output-escaping="yes">&lt;!doctype html&gt;</t:text>
    <t:apply-templates/>
  </t:template>
  <t:template match="child">
    <p>“<t:value-of select="."/>”</p>
  </t:template>
</t:stylesheet>