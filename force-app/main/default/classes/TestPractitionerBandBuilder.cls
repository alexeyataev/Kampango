@isTest
public with sharing class TestPractitionerBandBuilder {
    private Boolean insertRecord = false;
    private Contact practitioner;
    private String band = 'A';
    private Integer daysBeforeToday = 50;
    private Date startDate = Date.today() - daysBeforeToday;
    private Date endDate = null;
    
    public TestPractitionerBandBuilder insertRecord(Boolean insertRecord) {
        this.insertRecord = insertRecord;
        return this;
    }

    public TestPractitionerBandBuilder withPractitionerContact(Contact practitioner) {
        this.practitioner = practitioner;
        return this;
    }

    public TestPractitionerBandBuilder withBand(String band) {
        this.band = band;
        return this;
    }

    public TestPractitionerBandBuilder withStartDate(Date startDate) {
        this.startDate = startDate;
        return this;
    }

    public TestPractitionerBandBuilder withEndDate(Date endDate) {
        this.endDate = endDate;
        return this;
    }

    public Practitioner_Band__c build(){
        Practitioner_Band__c testBand = new Practitioner_Band__c(
            Practitioner__c = this.practitioner.Id,
            Band__c = this.band,
            Start_Date__c = this.startDate,
            End_Date__c = this.endDate
        );

		if(insertRecord)
		{
			insert testBand;
		}

		return testBand;
    }
}
