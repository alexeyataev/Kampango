public class CardPaymentHandler {
    @InvocableMethod
    public static List<CardPaymentUrlResult> getPaymentLink(List<CardPaymentParameters> parameters) {
        try {
            if(parameters == null || parameters.size() != 1 || parameters[0] == null) {
                throw new ListException('1 card payment parameter must be passed');
            }
            IPaymentServiceProvider paymentServiceProvider = new FinDockCardPaymentProvider();
            CardPaymentUrlResult result = paymentServiceProvider.getCardPaymentURL(parameters[0]);
            return new List<CardPaymentUrlResult> {result};
        } catch(Exception e) {
            CardPaymentUrlResult result = new CardPaymentUrlResult();
            result.error = e.getMessage();
            return new List<CardPaymentUrlResult> {result};
        }
    }
}