({
    myAction: function (component, event, helper) {
    },

    handleChange: function (component, event, helper) {
        let navigate = component.get("v.navigateFlow");
        navigate("NEXT");
    }
})