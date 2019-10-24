@isTest
public with sharing class TestBranchWeightingBuilder {
    private Boolean insertRecord = false;
    private Account branch;
    private String geographicalWeighting = 'Standard';
    private Date startDate = Date.today() - 5;
    private Date endDate = null;

    public TestBranchWeightingBuilder insertRecord(Boolean insertRecord){
        this.insertRecord = insertRecord;
        return this;
    }

    public TestBranchWeightingBuilder branch(Account branch){
        this.branch = branch;
        return this;
    }

    public TestBranchWeightingBuilder geographicalWeighting(String geographicalWeighting){
        this.geographicalWeighting = geographicalWeighting;
        return this;
    }

    public TestBranchWeightingBuilder startDate(Date startDate){
        this.startDate = startDate;
        return this;
    }

    public TestBranchWeightingBuilder endDate(Date endDate){
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
