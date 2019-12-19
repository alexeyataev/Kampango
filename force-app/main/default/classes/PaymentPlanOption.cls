public with sharing class PaymentPlanOption {
    @AuraEnabled @InvocableVariable public Decimal amountFirst;
    @AuraEnabled @InvocableVariable public Decimal amountRecurring;
    @AuraEnabled @InvocableVariable public Date startDate;
    @AuraEnabled @InvocableVariable public Date endDate;
    @AuraEnabled @InvocableVariable public String label;
    @AuraEnabled @InvocableVariable public String value;
}