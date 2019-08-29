@isTest
public with sharing class TestLicenceToPracticeBuilder {

    private Contact contact;
    private Date startDate = Date.Today();
    private String status = 'Full';
    private String licence = 'Postnatal Practitioner';
    private Boolean insertRecord = false;

    public TestLicenceToPracticeBuilder withContact(Contact contact)
    {
        this.contact = contact;
        return this;
    }

    public TestLicenceToPracticeBuilder withStartDate(Date startDate)
    {
        this.startDate = startDate;
        return this;
    }

    public TestLicenceToPracticeBuilder withStatus(String status)
    {
        this.status = status;
        return this;
    }

    public TestLicenceToPracticeBuilder withLicence(String licence)
    {
        this.licence = licence;
        return this;
    }

    public TestLicenceToPracticeBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public Licence_To_Practice__c build()
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