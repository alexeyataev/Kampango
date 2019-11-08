@isTest
public with sharing class TestBranchWeightingBuilder {
    private Boolean insertRecord = false;
    private Account branch;
    private String geographicalWeighting = 'Standard';
    private Integer daysBeforeToday = 50;
    private Date startDate = Date.today() - daysBeforeToday;
    private Date endDate = null;

    public TestBranchWeightingBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public TestBranchWeightingBuilder withBranch(Account branch){
        this.branch = branch;
        return this;
    }

    public TestBranchWeightingBuilder withWeighting(String geographicalWeighting){
        this.geographicalWeighting = geographicalWeighting;
        return this;
    }

    public TestBranchWeightingBuilder withStartDate(Date startDate){
        this.startDate = startDate;
        return this;
    }

    public TestBranchWeightingBuilder withEndDate(Date endDate){
        this.endDate = endDate;
        return this;
    }

    public Branch_Weighting__c build() {
        Branch_Weighting__c testWeighting = new Branch_Weighting__c(
            Branch__c = this.branch.Id,
            Geographical_Weighting__c = this.geographicalWeighting,
            Start_Date__c = this.startDate,
            End_Date__c = this.endDate
        );

		if(insertRecord)
		{
			insert testWeighting;
		}

		return testWeighting;
    }
}
