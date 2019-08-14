@isTest
public with sharing class TestSessionBuilder {

	private String name = 'testSession2';
	private String type = 'Standard';
	private Date sessionDate  = Date.today() + 5;
	private Time startTime = Time.newInstance(18, 30, 0, 0);
	private Time endTime = Time.newInstance(19, 30, 0, 00);
	private String specificAttendeeType = 'Women only';
	private String status = 'Confirmed';
	private Licence_To_Practice__c practitionerLicence;
	private Venue__c venue;
	private Course__c course;
	private Room__c room;
	private Boolean insertRecord = false;

	public TestSessionBuilder withName(String name)
	{
		this.name = name;
		return this;
	}

	public TestSessionBuilder withType(String type)
	{
		this.type = type;
		return this;
	}

	public TestSessionBuilder withDate(Date sessionDate)
	{
		this.sessionDate = sessionDate;
		return this;
	}

	public TestSessionBuilder withStartTime(Time startTime)
	{
		this.startTime = startTime;
		return this;
	}

	public TestSessionBuilder withEndTime(Time endTime)
	{
		this.endTime = endTime;
		return this;
	}

	public TestSessionBuilder withSpecificAttendeeType(String specificAttendeeType)
	{
		this.specificAttendeeType = specificAttendeeType;
		return this;
	}

	public TestSessionBuilder withStatus(String status)
	{
		this.status = status;
		return this;
	}

	public TestSessionBuilder withPractitionerLicence(Licence_To_Practice__c practitionerLicence)
	{
		this.practitionerLicence = practitionerLicence;
		return this;
	}

	public TestSessionBuilder withVenue(Venue__c venue)
	{
		this.venue = venue;
		return this;
	}

	public TestSessionBuilder withCourse(Course__c course)
	{
		this.course = course;
		return this;
	}

	public TestSessionBuilder withRoom(Room__c room)
	{
		this.room = room;
		return this;
	}

	public TestSessionBuilder insertRecord(Boolean insertRecord)
	{
		this.insertRecord = insertRecord;
		return this;
	}

	public Session__c build()
	{
		Session__c session = new Session__c(
			Course__c = this.course.Id,
			Name = this.name,
			Type__c = this.type,
			Date__c = this.sessionDate,
			Start__c = this.startTime,
			End__c = this.endTime,
			Specific_Attendee_Type__c = this.specificAttendeeType,
			Practitioner_Licence__c = this.practitionerLicence.Id,
			Venue__c = this.venue.Id,
			Room__c = this.room.Id,
			Status__c = this.status
		);

		if(insertRecord)
		{
			insert session;
		}

		return session;
	}
}