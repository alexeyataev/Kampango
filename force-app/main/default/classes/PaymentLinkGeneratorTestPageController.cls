public class PaymentLinkGeneratorTestPageController {
    public static String url {get;set;}
    public static String contactId {get;set;}
    public static String amount {get;set;}
    public static void generateLink() {
        url = StepOrangeCardPaymentProvider.getCardPaymentURL(contactId, amount);
    }
}