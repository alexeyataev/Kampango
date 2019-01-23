({
	doInit : function(component, event,helper) {
     
       var action = component.get("c.PaymentHubCallout");
       action.setParams({
           "contId": component.get("v.recordId") });
       
       
        
         action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {                
                var wasDismissed = $A.get("e.force:closeQuickAction");
                wasDismissed.fire();
                 
                var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     type : 'Success',
                 "title": "Success!",
                 "message": "Payment link sent successfully"
                });
                toastEvent.fire();
            } 
        });    
        $A.enqueueAction(action);   
    }
    
     
})