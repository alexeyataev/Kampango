public class PaymentPlanMockClock implements IClock {
    private Date currentDate;
    public PaymentPlanMockClock(Date currentDate) {
        this.currentDate = currentDate;
    }
    public Date today() {
        return currentDate;
    }
}