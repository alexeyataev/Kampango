@isTest
public with sharing class TestSessionBuilder {
	
	private Id courseId;
	private Datetime startTime = system.now();
	private Datetime endTime = system.now().addHours(2);

	private Boolean insertRecord = false;

	public TestSessionBuilder WithCourse(Id courseId)
	{
		this.courseId = courseId;
		return this;
	}

	public TestSessionBuilder WithStartTime(Datetime startTime)
	{
		this.startTime = startTime;
		return this;
	}

	public TestSessionBuilder WithEndTime(Datetime endTime)
	{
		this.endTime = endTime;
		return this;
	}


	public TestSessionBuilder InsertRecord(Boolean insertRecord)
	{
		this.insertRecord = insertRecord;
		return this;
	}


	public Session__c Build()
	{
		Session__c session = new Session__c(Course__c = courseId);

		if(insertRecord)
		{
			insert session;
		}

		return session;
	}
}