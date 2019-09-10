public class FlowPaymentHandler {
    @InvocableMethod
    public static List<String> GetPaymentLink(List<List<String>> params) {
        try {
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            String contactId = params[0][0];
            String feeAmount = params[0][1];
            return new List<String> {paymentServiceProvider.getCardPaymentURL(contactId, feeAmount)};
        } catch(Exception e) {
            return new List<String> {'error'};
        }
    }
}