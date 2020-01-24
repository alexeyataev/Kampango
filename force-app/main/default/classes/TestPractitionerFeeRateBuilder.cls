@isTest
public with sharing class TestPractitionerFeeRateBuilder {
    private Boolean insertRecord = false;
    private String geographicalWeighting = 'Standard';
    private String practitionerBand = 'A';
    private Decimal hourlyRate = 30.00;
    private Integer daysBeforeToday = 50;
    private Date startDate = Date.today() - daysBeforeToday;
    private Date endDate = null;

    public TestPractitionerFeeRateBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }
    public TestPractitionerFeeRateBuilder withWeighting(String geographicalWeighting){
        this.geographicalWeighting = geographicalWeighting;
        return this;
    }

    public TestPractitionerFeeRateBuilder withBand(String practitionerBand){
        this.practitionerBand = practitionerBand;
        return this;
    }

    public TestPractitionerFeeRateBuilder withHourlyRate(Decimal hourlyRate){
        this.hourlyRate = hourlyRate;
        return this;
    }

    public TestPractitionerFeeRateBuilder withStartDate(Date startDate){
        this.startDate = startDate;
        return this;
    }

    public TestPractitionerFeeRateBuilder withEndDate(Date endDate){
        this.endDate = endDate;
        return this;
    }

    public Practitioner_Fee_Rate__c build(){
        Practitioner_Fee_Rate__c testFeeRate = new Practitioner_Fee_Rate__c(
            Geographical_Weighting__c = this.geographicalWeighting,
            Practitioner_Band__c = this.practitionerBand,
            Hourly_Rate__c = this.hourlyRate,
            Start_Date__c = this.startDate,
            End_Date__c = this.endDate
        );
		if(insertRecord){
			insert testFeeRate;
		}
    	return testFeeRate;
    }
}