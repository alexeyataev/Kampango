public class PaymentHandler {
    @InvocableMethod
    public static List<String> getPaymentLink(List<List<String>> params) {
        IPaymentServiceProvider paymentServiceProvider = new WorldPayCardPaymentProvider();
        try {
            return paymentServiceProvider.getPaymentLink(params);
        } catch(Exception e) {
            return new List<String> {'error'};
        }
    }
}