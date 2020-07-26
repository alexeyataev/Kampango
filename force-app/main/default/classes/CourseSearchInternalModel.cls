public with sharing class CourseSearchInternalModel {

        @AuraEnabled public Date endDate;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Decimal confirmedPlaces;
        @AuraEnabled public Decimal remainingPlaces;
        @AuraEnabled public String deliveryType;
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String psaArea;
        @AuraEnabled public String status;
        @AuraEnabled public String subType;

        public CourseSearchInternalModel(Course__c courseRecord) {
            this.Id = courseRecord.Id;
            this.name = courseRecord.Name;
            this.subType = courseRecord.Sub_Type__c;
            this.startDate = courseRecord.Start_Date__c;
            this.endDate = courseRecord.End_Date__c;
            this.psaArea = courseRecord.PSA_Area__c;
            this.remainingPlaces = courseRecord.Remaining_Places__c;
            this.confirmedPlaces = courseRecord.Confirmed_Places__c;
            this.status = courseRecord.Status__c;
            this.deliveryType = Utils.getDeliveryMethod(courseRecord.Sessions__r);
        }
}
