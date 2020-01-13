public class CardPaymentPlanHandler {
    @InvocableMethod
    public static List<CardPaymentUrlResult> getPaymentLink(List<CardPaymentParameters> parameters) {
        try {
            if(parameters.size() != 1) {
                throw new ListException('List must contain 1 record');
            }
            IPaymentServiceProvider paymentServiceProvider = new FinDockCardPaymentProvider();
            CardPaymentUrlResult result = paymentServiceProvider.getCardPaymentPlanUrlForBooking(parameters[0]);
            return new List<CardPaymentUrlResult> {result};
        } catch(Exception e) {
            CardPaymentUrlResult result = new CardPaymentUrlResult();
            result.error = e.getMessage();
            return new List<CardPaymentUrlResult> {result};
        }
    }
}