public class SessionFeeHelperFlowAssistant {
    @InvocableMethod
    public static void assignFeeRatesToSessions(List<List<Session__c>> sessionsToProcess){
        for (List<Session__c> sessions : sessionsToProcess) {
            SessionFeeHelper.assignFeeRatesToSessions(sessions);
        }
    }
}
