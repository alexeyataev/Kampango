({
    init : function(component, event, helper) {
        const redirectUrl = '/edit-expense-sheet' + '?recordId=' + component.get("v.recordId");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          'url': redirectUrl
        });
        urlEvent.fire();
        setTimeout(
            function() { 
                $A.get("e.force:closeQuickAction").fire(); 
            }, 
            100
        );
    }
})