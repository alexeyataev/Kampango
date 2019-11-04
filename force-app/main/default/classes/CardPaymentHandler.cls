public class CardPaymentHandler {
    @InvocableMethod
    public static List<MembershipResultObject> getPaymentLink(List<cpm__Installment__c> installment) {
        try {
            String contactId = installment[0].cpm__Contact__c;
            String installmentId = installment[0].Id;
            IPaymentServiceProvider paymentServiceProvider = new StepOrangeCardPaymentProvider();
            String cardPaymentURL = paymentServiceProvider.GetCardPaymentURL(contactId, installmentId);
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = CareRequestBodyUtil.MESSAGE_TYPE_SUCCESS;
            membershipResultObject.messageText = cardPaymentURL;
            return new List<MembershipResultObject> {membershipResultObject};
        } catch(Exception e) {
            MembershipResultObject membershipResultObject = new MembershipResultObject();
            membershipResultObject.messageType = CareRequestBodyUtil.MESSAGE_TYPE_ERROR;
            membershipResultObject.messageText = CareRequestBodyUtil.MESSAGE_TEXT_ERROR;
            return new List<MembershipResultObject> {membershipResultObject};
        }
    }
}