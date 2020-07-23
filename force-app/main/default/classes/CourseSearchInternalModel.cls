public with sharing class CourseSearchInternalModel {
    
        @AuraEnabled public String name;
        @AuraEnabled public String subType;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String psaArea;
        @AuraEnabled public Decimal remainingPlaces;
        @AuraEnabled public Decimal confirmedPlaces;
        @AuraEnabled public String status;

        CourseSearchInternalModel(Course__c courseRecord) {
            this.name = courseRecord.Name;
            this.subType = courseRecord.Sub_Type__c;
            this.startDate = courseRecord.Start_Date__c;
            this.endDate = courseRecord.End_Date__c;
            this.psaArea = courseRecord.PSA_Area__c;
            this.remainingPlaces = courseRecord.Remaining_Places__c;
            this.confirmedPlaces = courseRecord.Confirmed_Places__c;
            this.status = courseRecord.Status__c;
        }
}
