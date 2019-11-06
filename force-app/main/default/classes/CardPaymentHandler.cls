public class CardPaymentHandler {
    @InvocableMethod
    public static List<BookingJourneyInvocableResult> getPaymentLink(List<cpm__Installment__c> installment) {
        try {
            String contactId = installment[0].cpm__Contact__c;
            String installmentId = installment[0].Id;
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            String cardPaymentURL = paymentServiceProvider.GetCardPaymentURL(contactId, installmentId);
            BookingJourneyInvocableResult result = new BookingJourneyInvocableResult();
            result.messageType = CareRequestBodyUtil.MESSAGE_TYPE_SUCCESS;
            result.messageText = cardPaymentURL;
            return new List<BookingJourneyInvocableResult> {result};
        } catch(Exception e) {
            BookingJourneyInvocableResult result = new BookingJourneyInvocableResult();
            result.messageType = CareRequestBodyUtil.MESSAGE_TYPE_ERROR;
            result.messageText = CareRequestBodyUtil.MESSAGE_TEXT_ERROR;
            return new List<BookingJourneyInvocableResult> {result};
        }
    }
}