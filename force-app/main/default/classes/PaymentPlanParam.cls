public with sharing class PaymentPlanParam {
    @AuraEnabled @InvocableVariable public String bookingId;
    @AuraEnabled @InvocableVariable public Decimal courseFee;
    @AuraEnabled @InvocableVariable public String contactId;
    @AuraEnabled @InvocableVariable public Date startDate;
}