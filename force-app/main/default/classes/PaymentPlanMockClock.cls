public class PaymentPlanMockClock implements IClock {
    private Integer daysToAdd = 0;
    public PaymentPlanMockClock(Integer daysToAdd) {
        this.daysToAdd = daysToAdd;
    }
    public Date today() {
        return Date.today().toStartOfMonth().addDays(daysToAdd);
    }
}