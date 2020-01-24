public interface IPaymentServiceProvider {
    CardPaymentUrlResult getCardPaymentPlanUrlForBooking(CardPaymentParameters parameters);
    CardPaymentUrlResult getCardPaymentUrl(CardPaymentParameters parameters);
}