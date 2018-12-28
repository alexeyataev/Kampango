@isTest
public with sharing class TestSessionBuilder {
	
	private Id courseId;
	private Datetime startTime = system.now();
	private Datetime endTime = system.now().addHours(2);

	private Boolean insertRecord = false;

	public TestSessionBuilder() {}

	public TestSessionBuilder withCourse(Id courseId)
	{
		this.courseId = courseId;
		return this;
	}

	public TestSessionBuilder withStartTime(Datetime startTime)
	{
		this.startTime = startTime;
		return this;
	}

	public TestSessionBuilder withEndTime(Datetime endTime)
	{
		this.endTime = endTime;
		return this;
	}


	public TestSessionBuilder insertRecord(Boolean insertRecord)
	{
		this.insertRecord = insertRecord;
		return this;
	}


	public Session__c build()
	{
		Session__c session = new Session__c(Course__c = courseId,
											Start__c = startTime,
											End__c = endTime);

		if(insertRecord)
		{
			insert session;
		}

		return session;
	}
}