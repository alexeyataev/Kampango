({

    doInit : function(component, event,helper) {
        
        var action = component.get("c.addToMembershipValidation");
        action.setParams({"contId": component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();  
              if(state === "SUCCESS"){
                  
                var urlEvent = $A.get("e.force:navigateToURL");
               urlEvent.setParams({
                "url": "/apex/nctETMembershipPaymentPage?id="+component.get("v.recordId")
              });

                 urlEvent.fire();
            }
               else if(state === "ERROR") {
                var wasDismissed = $A.get("e.force:closeQuickAction");
                wasDismissed.fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'error',
                title : 'Error Message',
                duration : '1000',
                message:'Membership already exists for this Contact'              
            });
            toastEvent.fire();
            }
            
          
        });
        $A.enqueueAction(action);
    }
    
    
})