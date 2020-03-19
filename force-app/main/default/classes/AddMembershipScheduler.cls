public with sharing class AddMembershipScheduler implements Schedulable {
	private static final Integer BATCH_SIZE = (Integer)Care_Settings__c.getOrgDefaults().Add_Membership_Batch_Size__c;
    private Integer updateIntervalHours = 1;
	public void execute(SchedulableContext sc) {
		if(sc != null)
		{
			System.abortJob(sc.getTriggerId());
		}
		System.schedule('AddMembershipScheduler', '0 0 ' + DateTime.now().addHours(updateIntervalHours).hour() + ' ? * *', this);
		runAddMembershipJob();
	}
	private static void runAddMembershipJob()
	{
		AddMembershipBatch addMembershipBatch = new AddMembershipBatch();
		Database.executeBatch(addMembershipBatch, BATCH_SIZE);	
	}
}