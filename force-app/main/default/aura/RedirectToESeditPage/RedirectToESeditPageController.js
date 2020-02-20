({
    init : function(component, event, helper) {
        var action = component.get("c.isExpenseSheetLocked");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(result) {
            if (result.getState() == "SUCCESS") {
                var isLocked = result.getReturnValue()
                component.set("v.isLocked", isLocked);
                if (!isLocked) {
                    const redirectUrl = '/edit-expense-sheet' + '?recordId=' + component.get("v.recordId");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                    'url': redirectUrl
                    });
                    urlEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire(); 
                }
            }
        });
        $A.enqueueAction(action);
    }
})