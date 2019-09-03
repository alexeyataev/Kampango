({
    handleComponentEvent : function(component, event, helper) {
        component.set("v.bookingId", event.getParam('value'));
    }
})