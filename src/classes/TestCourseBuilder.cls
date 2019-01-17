@isTest
public with sharing class TestCourseBuilder {
	
	private Integer places = 8;
	private Contact practitioner;
	private String psaOffice = '1C';
	private String psaBranch = 'Bridport';
	private String courseType = 'NCT Essentials';
	private Decimal fee = 200.00;
	private Boolean insertRecord = false;

	public TestCourseBuilder withPractitioner(Contact practitioner)
	{
		this.practitioner = practitioner;
		return this;
	}

	public TestCourseBuilder withPlaces(Integer places)
	{
		this.places = places;
		return this;
	}

	public TestCourseBuilder withPsaOffice(String psaOffice)
	{
		this.psaOffice = psaOffice;
		return this;
	}

	public TestCourseBuilder withPsaBranch(String psaBranch)
	{
		this.psaBranch = psaBranch;
		return this;
	}

	public TestCourseBuilder withCourseType(String courseType)
	{
		this.courseType = courseType;
		return this;
	}

	public TestCourseBuilder withFee(Decimal fee)
	{
		this.fee = fee;
		return this;
	}

	public TestCourseBuilder insertRecord(Boolean insertRecord)
	{
		this.insertRecord = insertRecord;
		return this;
	}

	public Course__c build()
	{
		Course__c course = new Course__c(Places__c = places,
											Practitioner__c = practitioner.Id,
											PSA_Office__c = psaOffice,
											PSA_Branch__c = psaBranch,
											Course_Type__c = courseType,
											Fee__c = fee);

		if(insertRecord)
		{
			insert course;
		}

		return course;
	}
}