global with sharing class SESSION_TrackDeletedRecord_TDTM extends npsp.TDTM_Runnable {
    global override npsp.TDTM_Runnable.DmlWrapper Run(List<SObject> triggerNew, List<SObject> triggerOld, npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        List<Session__c> oldSessionList = (List<Session__c>) triggerOld;

        if(triggerAction == npsp.TDTM_Runnable.Action.AfterDelete){
            postDeletedSessionsDetailsToChatter(oldSessionList);
        }

        return dmlWrapper;

    }    


    private void postDeletedSessionsDetailsToChatter(List<Session__c> oldSessionList) {
         
        Map<String, Object> params = new Map<String, Object>();
        params.put('sessionRecordsToTrack', oldSessionList);
        Flow.Interview.Track_Deleted_Sessions trackDeletedSessions = new Flow.Interview.Track_Deleted_Sessions(params);
        trackDeletedSessions.start();
    }
}