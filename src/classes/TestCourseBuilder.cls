@isTest
public with sharing class TestCourseBuilder {
	
	private Integer places = 8;
	private Contact practitioner;
	private String psaOffice = '1C';
	private String psaBranch = 'Bridport';
	private String courseType = 'NCT Essentials';
	private Decimal fee = 200.00;
	private Boolean insertRecord = false;

	public TestCourseBuilder() {}

	public TestCourseBuilder WithPractitioner(Contact practitioner)
	{
		this.practitioner = practitioner;
		return this;
	}

	public TestCourseBuilder WithPlaces(Integer places)
	{
		this.places = places;
		return this;
	}

	public TestCourseBuilder WithPsaOffice(String psaOffice)
	{
		this.psaOffice = psaOffice;
		return this;
	}

	public TestCourseBuilder WithPsaBranch(String psaBranch)
	{
		this.psaBranch = psaBranch;
		return this;
	}

	public TestCourseBuilder WithCourseType(String courseType)
	{
		this.courseType = courseType;
		return this;
	}

	public TestCourseBuilder WithFee(Decimal fee)
	{
		this.fee = fee;
		return this;
	}

	public TestCourseBuilder InsertRecord(Boolean insertRecord)
	{
		this.insertRecord = insertRecord;
		return this;
	}

	public Course__c Build()
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