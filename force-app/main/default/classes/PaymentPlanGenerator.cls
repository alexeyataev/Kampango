public with sharing class PaymentPlanGenerator {
    @TestVisible private static IClock clock = new SystemClock();
    private static Date initialPaymentDate;
    private static final Integer MAX_DAYS_BEFORE_PAID = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Maximum_Days_Before_Paid__c);
    private static final Integer MAX_RECURRING_INSTALLMENTS_NUMBER = 3;
    private static final Integer MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Min_Days_Before_First_Recurring_Payment__c);
    private static final Decimal MIN_FIRST_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimum_First_Amount__c;
    private static final Decimal MIN_REC_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimum_Recurring_Amount__c;
    public static List<PaymentPlanOption> getOptions(Decimal courseFee, Date courseStartDate) {
        initialPaymentDate = clock.today();
        Date firstRecurringPaymentDate = getFirstRecurringPaymentDate();
        List<PaymentPlanOption> paymentPlanOptions = new List<PaymentPlanOption>();
        for(Integer i = 1; i <= MAX_RECURRING_INSTALLMENTS_NUMBER; i++) {
            if(isPaidBeforeCourseStartDate(i, courseStartDate, firstRecurringPaymentDate)) {
                PaymentPlanOption paymentPlanOption = calculateAmounts(courseFee, i);
                if(paymentPlanOption != null) {
                    Date lastPaymentDate = firstRecurringPaymentDate.addMonths(i - 1);
                    paymentPlanOption.startDate = firstRecurringPaymentDate.toStartOfMonth();
                    paymentPlanOption.endDate = lastPaymentDate.toStartOfMonth() + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1;
                    paymentPlanOption.label = createOptionLabel(paymentPlanOption, i);
                    paymentPlanOption.value = String.valueOf(i);
                    paymentPlanOptions.add(paymentPlanOption);
                }
            }
        }
        return paymentPlanOptions;
    }
    private static Date getFirstRecurringPaymentDate() {
        Date firstRecurringPaymentDate;
        Integer daysInCurrentMonth = Date.daysInMonth(initialPaymentDate.year(), initialPaymentDate.month());
        Integer daysToday = initialPaymentDate.day();
        firstRecurringPaymentDate = initialPaymentDate.addDays(daysInCurrentMonth - daysToday + 1);
        if(daysInCurrentMonth - daysToday <= MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT) {
            firstRecurringPaymentDate = firstRecurringPaymentDate.addMonths(1);
        }
        return firstRecurringPaymentDate;
    }
    private static Boolean isPaidBeforeCourseStartDate(Integer monthCount, Date courseStartDate, Date firstRecurringPaymentDate) {
        return firstRecurringPaymentDate.addMonths(monthCount - 1).addDays(MAX_DAYS_BEFORE_PAID) < courseStartDate;
    }
    @TestVisible
    private static PaymentPlanOption calculateAmounts(Decimal courseFee, Integer monthCount) {
        PaymentPlanOption paymentPlanOption = new PaymentPlanOption();
        if(courseFee >= MIN_FIRST_AMOUNT + MIN_REC_AMOUNT * monthCount && courseFee < MIN_FIRST_AMOUNT * (monthCount + 1)) {
            paymentPlanOption.amountFirst = MIN_FIRST_AMOUNT;
        } else
        if(courseFee >= MIN_FIRST_AMOUNT * (monthCount + 1)) {
            paymentPlanOption.amountFirst = courseFee/(monthCount + 1);
        } else {
            return null;
        }
        paymentPlanOption.amountFirst = paymentPlanOption.amountFirst.setScale(2, System.RoundingMode.CEILING);
        Decimal amountRest = courseFee - paymentPlanOption.amountFirst;
        paymentPlanOption.amountRecurring = (amountRest/monthCount).setScale(2, System.RoundingMode.DOWN);
        paymentPlanOption.amountFirst += (amountRest - paymentPlanOption.amountRecurring * monthCount);
        return paymentPlanOption;
    }
    private static String createOptionLabel(PaymentPlanOption paymentPlanOption, Integer monthCount) {
        String labelText;
        if(paymentPlanOption.amountFirst == paymentPlanOption.amountRecurring) {
            String labelTemplate = Label.Payment_Plan_Equal_Amounts_Option_Template;
            labelText = String.format(labelTemplate, new List<Object> {monthCount + 1, paymentPlanOption.amountRecurring});
        } else {
            String labelTemplate = Label.Payment_Plan_Different_Amounts_Option_Template;
            labelText = String.format(labelTemplate, new List<Object> {paymentPlanOption.amountFirst, monthCount, paymentPlanOption.amountRecurring});
        }
        return labelText;
    }
}