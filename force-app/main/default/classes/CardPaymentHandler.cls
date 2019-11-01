public class CardPaymentHandler {
    public static final String MESSAGE_TYPE_SUCCESS = 'success';
    public static final String MESSAGE_TYPE_ERROR = 'error';
    public static final String MESSAGE_TEXT_ERROR = 'error!';
    @InvocableMethod
    public static List<MembershipResultObject> getPaymentLink(List<cpm__Installment__c> installment) {
        try {
            String contactId = installment[0].cpm__Contact__c;
            String installmentId = installment[0].Id;
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            String cardPaymentURL = paymentServiceProvider.GetCardPaymentURL(contactId, installmentId);
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = MESSAGE_TYPE_SUCCESS;
            membershipResultObject.messageText = cardPaymentURL;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = MESSAGE_TYPE_ERROR;
            membershipResultObject.messageText = MESSAGE_TEXT_ERROR;
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
}