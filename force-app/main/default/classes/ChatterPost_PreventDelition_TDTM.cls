//@SuppressWarnings('PMD.AvoidGlobalModifier')
//Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
global with sharing class ChatterPost_PreventDelition_TDTM extends npsp.TDTM_Runnable {
    private static Boolean hasCustomPermission = FeatureManagement.checkPermission('Can_Delete_Chatter_Posts');
    //@SuppressWarnings('PMD.ExcessiveParameterList')
    //Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<FeedItem> oldFeedItemList = (List<FeedItem>) triggerOld;

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeDelete && !hasCustomPermission) {
            preventChatterPostDeletion(oldFeedItemList);
        }
        return dmlWrapper;
    }

    private void preventChatterPostDeletion(List<FeedItem> oldFeedItemList) {
        for (FeedItem feed : oldFeedItemList) {
            feed.addError(System.label.Delete_Chatter_Post_Error_Text);
        }
    }
}