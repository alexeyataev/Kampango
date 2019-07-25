({
    doInit : function(component, event, helper) {
        var parseUrl = new URL(window.location.href);
        component.set('v.bookingId', parseUrl.searchParams.get("bookingId"));
    }
})
