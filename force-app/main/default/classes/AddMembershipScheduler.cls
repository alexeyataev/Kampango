public with sharing class AddMembershipScheduler implements Schedulable {
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
		Database.executeBatch(addMembershipBatch);	
	}
}