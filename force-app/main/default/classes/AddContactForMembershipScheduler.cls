public with sharing class AddContactForMembershipScheduler implements Schedulable {
    private static final Integer BATCH_SIZE = (Integer)Care_Settings__c.getOrgDefaults().Add_Contact_Batch_Size__c;
    private Integer updateIntervalHours = 1;
    public void execute(SchedulableContext sc) {
        if(sc != null)
        {
            System.abortJob(sc.getTriggerId());
        }
        System.schedule('AddContactForMembershipScheduler', '0 0 ' + DateTime.now().addHours(updateIntervalHours).hour() + ' ? * *', this);
        runAddMembershipJob();
    }
    private static void runAddMembershipJob()
    {
        AddContactForMembershipBatch addContactForMembershipBatch = new AddContactForMembershipBatch();
        Database.executeBatch(addContactForMembershipBatch, BATCH_SIZE);	
    }
}