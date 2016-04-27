<?xml version="1.0" encoding="UTF-8"?>
<%
    java.util.Properties props = System.getProperties();
    String serverName = props.getProperty ("jboss.server.name");
    serverName = ( serverName != null ) ? serverName : "";
%>
<framework>
    <server value="<%=serverName%>"/>
    <build value="@project.version@"/>
    <release value="@project.version@"/>
</framework>
