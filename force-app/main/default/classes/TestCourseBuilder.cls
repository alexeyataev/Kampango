@isTest
public with sharing class TestCourseBuilder {
    private String type = 'Antenatal';
    private String subType  ='One to One';
    private Integer fee = 100;
    private Integer numberOfPlaces = 1;
    private String status = 'Draft';
    private Account account;
    private Licence_To_Practice__c licenceToPractice;
    private Boolean insertRecord = false;

    public TestCourseBuilder WithType(String type)
    {
        this.type = type;
        return this;
    }

    public TestCourseBuilder WithSubType(String subType)
    {
        this.subType = subType;
        return this;
    }

    public TestCourseBuilder WithSFee(Integer fee)
    {
        this.fee = fee;
        return this;
    }
    public TestCourseBuilder WithNumberOfPlaces(Integer numberOfPlaces)
    {
        this.numberOfPlaces = numberOfPlaces;
        return this;
    }

    public TestCourseBuilder WithStatus(String status)
    {
        this.status = status;
        return this;
    }
    public TestCourseBuilder WithAccount(Account account)
    {
        this.account = account;
        return this;
    }
    public TestCourseBuilder WithLicenceToPractice(Licence_To_Practice__c licenceToPractice)
    {
        this.licenceToPractice = licenceToPractice;
        return this;
    }
    public TestCourseBuilder InsertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public Course__c Build()
    {
        Course__c course = new Course__c(
            Type__c = this.type,
            Sub_Type__c = this.subType,
            Fee__c = this.fee,
            Status__c = this.status,
            Number_of_places__c = this.numberOfPlaces,
            Branch__c = this.account.Id,
            Main_Practitioner_Licence__c = this.licenceToPractice.Id
        );

        if(insertRecord)
        {
            insert course;
        }

        return course;
    }
}