public with sharing class PaymentPlanOption {
    @AuraEnabled @InvocableVariable public Decimal amountFirst;
    @AuraEnabled @InvocableVariable public Decimal amountRecurring;
    @AuraEnabled @InvocableVariable public Date startDate;
    @AuraEnabled @InvocableVariable public Date endDate;
    @AuraEnabled @InvocableVariable public String displayLabel;
    @AuraEnabled @InvocableVariable public String numberOfPayments;
}