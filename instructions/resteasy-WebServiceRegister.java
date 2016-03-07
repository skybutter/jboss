package rest.ws;

import java.util.HashSet;
import java.util.Set;
import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;
import rest.ws.WhateverWebService;

@ApplicationPath("/")
public class WebServiceRegister extends Application {
    @Override
    public Set<Class<?>> getClasses() {
        final Set<Class<?>> classes = new HashSet<Class<?>>();
        classes.add(WhateverWebService.class);
        return classes;
    }
}
