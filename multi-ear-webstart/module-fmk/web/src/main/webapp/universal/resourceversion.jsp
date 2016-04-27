<%!
public static java.util.Set<String> resourcePaths = null;

public static final String webapp = "/framework";
public static final String jnlpResourcePath = "webstart/";

public java.util.Set<String> getResourcePaths() {
	synchronized (this) {
		if (resourcePaths==null || resourcePaths.isEmpty()) {
			resourcePaths = getServletContext().getResourcePaths("/" + jnlpResourcePath);			
		}
	}
	return resourcePaths;
}
%>
<%
java.util.Set<String> resources = getResourcePaths();

	if (resources!=null && !resources.isEmpty()) {
		java.util.Iterator<String> it = resources.iterator();		
		while (it.hasNext()) {
			String resource = it.next();
			StringBuilder sb = new StringBuilder();
			// Only include jar file here, must start with "/", otherwise won't download properly
			String mainClass = "";
			if (resource.endsWith(".jar")) {
				String filepath = webapp + resource;
				if (resource.indexOf("client-") > -1) {
				    mainClass = " main='true' ";
				}
				sb.append("<jar href='" + filepath + "' " + mainClass + "/>\n");
				out.println(sb.toString());
			}
		}
	} else {
		System.out.println("ERROR: ***** No resources found for " + webapp +  " ******");
	}
%>
