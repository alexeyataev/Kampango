@isTest
public with sharing class TestPractitionerFeeRateBuilder {
    private Boolean insertRecord = false;
    private String geographicalWeighting = 'Standard';
    private String practitionerBand = 'A';
    private Decimal hourlyRate = 30.00;

    public TestPractitionerFeeRateBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }
    public TestPractitionerFeeRateBuilder geographicalWeighting(String geographicalWeighting){
        this.geographicalWeighting = geographicalWeighting;
        return this;
    }

    public TestPractitionerFeeRateBuilder practitionerBand(String practitionerBand){
        this.practitionerBand = practitionerBand;
        return this;
    }

    public TestPractitionerFeeRateBuilder hourlyRate(Decimal hourlyRate){
        this.hourlyRate = hourlyRate;
        return this;
    }

    public Practitioner_Fee_Rate__c build(){
        Practitioner_Fee_Rate__c testFeeRate = new Practitioner_Fee_Rate__c(
            Geographical_Weighting__c = this.geographicalWeighting,
            Practitioner_Band__c = this.practitionerBand,
            Hourly_Rate__c = this.hourlyRate
        );
		if(insertRecord){
			insert testFeeRate;
		}
    	return testFeeRate;
    }
}
