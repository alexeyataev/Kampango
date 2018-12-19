@isTest
public with sharing class TestBookingBuilder {
	
	private String status = 'Enquiry';
	private Contact client;
	private Course__c course;
	private Date dueDate = system.today() + 120;
	private Boolean insertRecord = false;

	public TestBookingBuilder() {}

	public TestBookingBuilder WithStatus(String status)
	{
		this.status = status;
		return this;
	}

	public TestBookingBuilder WithClient(Contact client)
	{
		this.client = client;
		return this;
	}

	public TestBookingBuilder WithCourse(Course__c course)
	{
		this.course = course;
		return this;
	}

	public TestBookingBuilder WithDueDate(Date dueDate)
	{
		this.dueDate = dueDate;
		return this;
	}

	public TestBookingBuilder InsertRecord(Boolean insertRecord)
	{
		this.insertRecord = insertRecord;
		return this;
	}

	public Booking__c Build()
	{
		Booking__c booking = new Booking__c(Status__c = status,
											Client__c = client.Id,
											Course__c = course.Id,
											Due_Date__c = dueDate);

		if(insertRecord)
		{
			insert booking;
		}

		return booking;
	}
}