@isTest
public with sharing class TestSessionBuilder {

	private final String SCHEDULED_SESSION = 'Scheduled_Session';
	private final String ADHOC_SUPPORT_SESSION = 'Adhoc_Support';
	private String type = 'Standard';
	private Integer daysAfterToday = 5;
	private Integer hours;
	private Date sessionDate  = Date.today() + daysAfterToday;
	private Time startTime = Time.newInstance(18, 30, 0, 0);
	private Time endTime = Time.newInstance(19, 30, 0, 00);
	private String specificAttendeeType = 'Women only';
	private String status = 'Confirmed';
	private String deliveryType = 'Physical';
	private Licence_To_Practice__c practitionerLicence;
	private Venue__c venue;
	private Course__c course;
	private Room__c room;
	private Contact practitioner;
	private Contact parentHost;
	private Boolean insertRecord = false;
	private Practitioner_Fee_Rate__c practitionerFeeRate;
	private Id sessionRecordTypeId;

	public TestSessionBuilder withPractitioner(Contact practitioner)
	{
		this.practitioner = practitioner;
		return this;
	}

	public TestSessionBuilder withPractitionerFeeRate(Practitioner_Fee_Rate__c practitionerFeeRate)
	{
		this.practitionerFeeRate = practitionerFeeRate;
		return this;
	}

	public TestSessionBuilder withType(String type)
	{
		this.type = type;
		return this;
	}

	public TestSessionBuilder withParentHost(Contact parentHost) {
		this.parentHost = parentHost;
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

	public TestSessionBuilder withDeliveryType(String deliveryType)
	{
		this.deliveryType = deliveryType;
		return this;
	}

	public TestSessionBuilder withHours(Integer hours)
	{
		this.hours = hours;
		if (hours != null) {
			this.sessionDate = null;
			this.startTime = null;
			this.endTime = null;
		}
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
			Type__c = this.type,
			Delivery_Type__c = this.deliveryType,
			Hours__c = this.hours,
			Date__c = this.sessionDate,
			Start__c = this.startTime,
			End__c = this.endTime,
			Specific_Attendee_Type__c = this.specificAttendeeType,
			Status__c = this.status,
			Practitioner__c = this.practitioner.Id,
			Practitioner_Licence__c = this.practitionerLicence.Id,
			Practitioner_Fee_Rate__c = this.practitionerFeeRate != Null ? this.practitionerFeeRate.Id : Null,
			RecordTypeId = deliveryType != 'Virtual Support' ? Schema.SObjectType.Session__c.getRecordTypeInfosByDeveloperName().get(SCHEDULED_SESSION).getRecordTypeId()
                        : Schema.SObjectType.Session__c.getRecordTypeInfosByDeveloperName().get(ADHOC_SUPPORT_SESSION).getRecordTypeId()
		);
		if (parentHost != null) {
			session.Parent_Host__c = this.parentHost.Id;
		} else {
			if (venue != null) {
				session.Venue__c = this.venue.Id;
			}
			if (room != null) {
				session.Room__c = this.room.Id;
			}
		}

		if(insertRecord)
		{
			insert session;
		}

		return session;
	}
}