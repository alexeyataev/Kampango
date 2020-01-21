public with sharing class PaymentPlanOptionsController {
    @AuraEnabled(cacheable=true)
    public static List<PaymentPlanOption> getOptions(Decimal courseFee, Date courseStartDate) {
        return PaymentPlanGenerator.getOptions(courseFee, courseStartDate);
    }
}