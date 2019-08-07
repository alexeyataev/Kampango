@isTest
public with sharing class TestLicenceToPracticeBuilder {

    private Contact contact;
    private Date startDate = Date.Today();
    private String status = 'Full';
    private String licence = 'Postnatal Practitioner';
    private Boolean insertRecord = false;

    public TestLicenceToPracticeBuilder WithContact(Contact contact)
    {
        this.contact = contact;
        return this;
    }

    public TestLicenceToPracticeBuilder WithStartDate(Date startDate)
    {
        this.startDate = startDate;
        return this;
    }

    public TestLicenceToPracticeBuilder WithStatus(String status)
    {
        this.status = status;
        return this;
    }

    public TestLicenceToPracticeBuilder WithLicence(String licence)
    {
        this.licence = licence;
        return this;
    }

    public TestLicenceToPracticeBuilder InsertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public Licence_To_Practice__c Build()
    {
        Licence_To_Practice__c licenceToPractice = new Licence_To_Practice__c(
            Contact__c = this.contact.Id,
            Start_Date__c = this.startDate,
            Status__c = this.status,
            Licence__c = this.licence
        );

        if(insertRecord)
        {
            insert licenceToPractice;
        }

        return licenceToPractice;
    }

}