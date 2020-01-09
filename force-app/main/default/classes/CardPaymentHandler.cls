public class CardPaymentHandler {
    @InvocableMethod
    public static List<CardPaymentUrlResult> getPaymentLink(List<CardPaymentUrlRequest> params) {
        try {
            if(params.size() != 1) {
                throw new ListException('List must contain 1 record');
            }
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            CardPaymentUrlResult result = paymentServiceProvider.getCardPaymentURL(params[0].installment, params[0].bookingId);
            return new List<CardPaymentUrlResult> {result};
        } catch(Exception e) {
            CardPaymentUrlResult result = new CardPaymentUrlResult();
            result.error = e.getMessage();
            return new List<CardPaymentUrlResult> {result};
        }
    }
}