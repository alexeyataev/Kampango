public interface IPaymentServiceProvider {
    List<String> getPaymentLink(List<List<String>> params);
}