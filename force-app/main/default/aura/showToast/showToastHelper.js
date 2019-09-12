({
    showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "duration": 2000,
            "mode": "dismissible",
        });
        toastEvent.fire();
    }
})