({
    init : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          'url': '/edit-expense-sheet' + '?recordId=' + component.get("v.recordId")
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