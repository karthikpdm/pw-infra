package com.pw.lambda;

import java.util.HashMap;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import software.amazon.awssdk.services.location.LocationClient;
import software.amazon.awssdk.services.location.model.UpdateTrackerRequest;

public class EnableEventBridge implements RequestHandler<HashMap<String, Object>, String>{

    public LocationClient locationClient;

    public EnableEventBridge(){
        this(LocationClient.create());
    }

    public EnableEventBridge(LocationClient locationClient) {
        this.locationClient = locationClient;
    }

    @Override
    public String handleRequest(HashMap<String, Object> event, Context context) {
        String tracker = (String) event.get("trackerName");

       UpdateTrackerRequest request = UpdateTrackerRequest.builder()
                                        .trackerName(tracker)
                                        .eventBridgeEnabled(true)
                                        .build();

        try {
            locationClient.updateTracker(request);
        } catch (Exception e) {
            context.getLogger().log("Error while updating tracker" + e.getMessage());
        }

        return "success";
    }  
}
