@isTest
public with sharing class TestCourseBuilder {
    private String type = 'Antenatal';
    private String subType  ='NCT Essentials antenatal course';
    private Integer fee = 100;
    private Integer numberOfPlaces = 1;
    private String status = 'Draft';
    private Account account;
    private Licence_To_Practice__c licenceToPractice;
    private Boolean insertRecord = false;
    private Venue__c mainVenue;
    private Contact practitioner;
    private Integer totalPractitionerFees = 200;
    private Integer estimatedTravelCosts = 100;
    private Integer estimatedVenueCosts = 100;

    public TestCourseBuilder withType(String type)
    {
        this.type = type;
        return this;
    }

    public TestCourseBuilder withSubType(String subType)
    {
        this.subType = subType;
        return this;
    }

    public TestCourseBuilder withFee(Integer fee)
    {
        this.fee = fee;
        return this;
    }
    public TestCourseBuilder withNumberOfPlaces(Integer numberOfPlaces)
    {
        this.numberOfPlaces = numberOfPlaces;
        return this;
    }

    public TestCourseBuilder withStatus(String status)
    {
        this.status = status;
        return this;
    }
    public TestCourseBuilder withAccount(Account account)
    {
        this.account = account;
        return this;
    }
    public TestCourseBuilder withMainVenue(Venue__c mainVenue)
    {
        this.mainVenue = mainVenue;
        return this;
    }
    public TestCourseBuilder withLicenceToPractice(Licence_To_Practice__c licenceToPractice)
    {
        this.licenceToPractice = licenceToPractice;
        return this;
    }
    public TestCourseBuilder withPractitioner(Contact practitioner)
    {
        this.practitioner = practitioner;
        return this;
    }
    public TestCourseBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public Course__c build()
    {
        Course__c course = new Course__c(
            Type__c = this.type,
            Sub_Type__c = this.subType,
            Fee__c = this.fee,
            Status__c = this.status,
            Number_of_places__c = this.numberOfPlaces,
            Branch__c = this.account.Id,
            Main_Practitioner__c = this.practitioner.Id,
            Main_Practitioner_Licence__c = this.licenceToPractice.Id,
            Main_Venue__c = mainVenue.Id,
            Total_Practitioner_Fees__c = this.totalPractitionerFees,
            Estimated_Travel_Costs__c = this.estimatedTravelCosts,
            Estimated_Venue_Costs__c = this.estimatedVenueCosts
        );

        if(insertRecord)
        {
            insert course;
        }

        return course;
    }
}