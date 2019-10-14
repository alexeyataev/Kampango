public interface IPaymentServiceProvider {
    String getCardPaymentURL(String contactId, String feeAmount);
}