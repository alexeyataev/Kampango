@isTest
public with sharing class TestEstimatedCostsBuilder {

    private String type = 'Travel';
    private Course__c course;
    private Integer amount = 100;
    private Boolean insertRecord = false;

    public TestEstimatedCostsBuilder withType(String type)
    {
        this.type = type;
        return this;
    }

    public TestEstimatedCostsBuilder withCourse(Course__c course)
    {
        this.course = course;
        return this;
    }

    public TestEstimatedCostsBuilder withAmount(Integer amount)
    {
        this.amount = amount;
        return this;
    }

    public TestEstimatedCostsBuilder insertRecord(Boolean insertRecord)
    {
        this.insertRecord = insertRecord;
        return this;
    }

    public Estimated_Costs__c build()
    {
        Estimated_Costs__c estimatedCosts = new Estimated_Costs__c(
            Type__c = this.type,
            Course__c = this.course.Id,
            Amount__c = this.amount
        );

        if(insertRecord)
        {
            insert estimatedCosts;
        }

        return estimatedCosts;
    }
}