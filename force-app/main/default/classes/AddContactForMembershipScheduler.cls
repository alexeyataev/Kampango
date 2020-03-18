public with sharing class AddContactForMembershipScheduler implements Schedulable {
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
        Database.executeBatch(addContactForMembershipBatch, 100);	
    }
}