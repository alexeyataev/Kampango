({
	membershipCreate : function(component) {
        var action = component.get("c.membershipInsert");
       action.setParams({"contId": component.get("v.recordId") });
       action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var wasDismissed = $A.get("e.force:closeQuickAction");
                wasDismissed.fire();
                var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     type : 'Success',
                 "title": "Success!",
                 "message": "Membership Created successfully"
                });
                toastEvent.fire();
            }
               if(state === "ERROR") {
                var wasDismissed = $A.get("e.force:closeQuickAction");
                wasDismissed.fire();
                var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     type : 'Error',
                 "title": "Error!",
                 "message": "Membership already exists for this contact."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
		
	}
})