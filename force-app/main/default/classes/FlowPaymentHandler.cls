public class FlowPaymentHandler {
    @InvocableMethod
    public static List<String> getPaymentLink(List<List<String>> params) {
        try {
            IPaymentServiceProvider paymentServiceProvider = new WorldPayCardPaymentProvider();
            String contactId = params[0][0];
            String feeAmount = params[0][1];
            return new List<String> {paymentServiceProvider.GetCardPaymentURL(contactId, feeAmount)};
        } catch(Exception e) {
            return new List<String> {'error'};
        }
    }
}