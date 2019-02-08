({
    doInit : function(component, event,helper) {
        var action = component.get("c.addToMembershipValidation");
        action.setParams({"contId": component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var wasDismissed = $A.get("e.force:closeQuickAction");
                wasDismissed.fire();
            var state = response.getState();  
            if(state === "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'You Cant Add Membership, hence already membership exists for this contact',
                messageTemplate: 'Mode is pester ,duration is 10sec and Message is overrriden',
                duration:' 10000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            }
              else if(state === "SUCCESS"){
                var urlEvent = $A.get("e.force:navigateToURL");
               urlEvent.setParams({
                "url": "/apex/nctETMembershipPaymentPage?id="+component.get("v.recordId")
              });

                 urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
    
    
})