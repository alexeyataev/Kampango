public interface IPaymentServiceProvider {
    String GetCardPaymentURL(String contactId, String feeAmount);
}