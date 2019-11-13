public class CardPaymentHandler {
    @InvocableMethod
    public static List<CardPaymentUrlResult> getPaymentLink(List<cpm__Installment__c> installment) {
        try {
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            CardPaymentUrlResult result = paymentServiceProvider.getCardPaymentURL(installment[0]);
            return new List<CardPaymentUrlResult> {result};
        } catch(Exception e) {
            CardPaymentUrlResult result = new CardPaymentUrlResult();
            result.error = e.getMessage();
            return new List<CardPaymentUrlResult> {result};
        }
    }
}