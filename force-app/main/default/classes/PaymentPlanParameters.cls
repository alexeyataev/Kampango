public with sharing class PaymentPlanParameters {
    @AuraEnabled @InvocableVariable public String bookingId;
    @AuraEnabled @InvocableVariable public Decimal courseFee;
    @AuraEnabled @InvocableVariable public String contactId;
    @AuraEnabled @InvocableVariable public Date startDate;
}