package rest.ws;

import java.rmi.RemoteException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.QueryParam;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.core.Response;

@Path("/ws")
public class WhateverWebService {

    private static final Logger LOGGER = Logger.getLogger(WhateverWebService.class.getName());
    
//  Sample call: wget "http://server:8181/appname/rest/ws/soccer/{id}" -O output.txt
    @GET
    @Path("/soccer/{soccerId}")
    @Produces("application/json")
    public Response getSoccer(@PathParam("soccerId") Integer soccerId) {
    	Object results = null;
        try {
            if(soccerId == null){
                throw new Exception("Invalid soccerId: null");
            }
            LOGGER.log(Level.INFO, "starting to call: " + soccerId);			
            Soccer soccer = null;
			// do something
            results = soccer;
            LOGGER.log(Level.INFO, soccerId + " process complete");            
        } catch (Throwable t){
            LOGGER.log(Level.SEVERE, "Unable to complete process",t);
            results = "Exception result";
        }
        return Response.ok(results).build();
    }

	// Using both PathParam and QueryParam
    @GET
    @Path("/soccerResults/{soccerId}")
    @Produces("application/json")
    public Response getAnalytics(@PathParam("soccerId") Integer soccerId,
    		@QueryParam("start") String dateStr ) {
    	Object results = null;
        try {
            if(soccerId == null) {
                throw new Exception("Invalid soccerId: null");
            }
            if (dateStr == null) {
            	throw new Exception("Invalid date: null");
            }
            // do something
			// results = SoccerResults...
        } catch (Throwable t){
            LOGGER.log(Level.SEVERE, "Unable to complete process",t);
            results = "Exception result";
        }
        return Response.ok(results).build();
    }

    @POST
    @Path("/searchSoccer")
    @Consumes("application/json")
    @Produces("application/json")
    public Response searchsoccer(Soccer params) {
    	LOGGER.log(Level.INFO, "Soccer:" + params);
    	Object results = null;
        try {
            if(params == null) {
                throw new Exception("Invalid soccer search parameter");
            }
			// Do something with Soccer params
			// results = searchResults
        } catch (Throwable t){
            LOGGER.log(Level.SEVERE, "Unable to search soccer", t);
            results = Collections.EMPTY_LIST;
        }
        return Response.ok(results).build();
    }
}