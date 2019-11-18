public interface IPaymentServiceProvider {
    CardPaymentUrlResult getCardPaymentURL(cpm__Installment__c installment);
}