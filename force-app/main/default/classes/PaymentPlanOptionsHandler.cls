public with sharing class PaymentPlanOptionsHandler {
    @TestVisible private static Date initialPaymentDate = Date.today();
    private static final Integer MAX_DAYS_BEFORE_PAID = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Maximum_Days_Before_Paid__c);
    private static final Integer MAX_RECURRING_INSTALLMENTS_NUMBER = 3;
    private static final Integer MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Min_Days_Before_First_Recurring_Payment__c);
    private static final Decimal MIN_FIRST_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimal_First_Amount__c;
    private static final Decimal MIN_REC_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimal_Recurring_Amount__c;
    @InvocableMethod
    public static List<List<PaymentPlanOption>> getOptions(List<PaymentPlanParameters> paymentPlanParameters) {
        PaymentPlanParameters paymentPlanParameter = paymentPlanParameters[0];
        paymentPlanParameter.firstRecurringPaymentDate = getFirstRecurringPaymentDate();
        List<PaymentPlanOption> paymentPlanOptions = new List<PaymentPlanOption>();
        for(Integer i = 1; i <= MAX_RECURRING_INSTALLMENTS_NUMBER; i++) {
            paymentPlanParameter.monthCount = i;
            addOption(paymentPlanOptions, paymentPlanParameter);
        }
        return new List<List<PaymentPlanOption>> {paymentPlanOptions};
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
    private static void addOption(List<PaymentPlanOption> paymentPlanOptions, PaymentPlanParameters paymentPlanParameter) {
        if(isPaidBeforeCourseStartDate(paymentPlanParameter)) {
            calculateAmounts(paymentPlanParameter);
            if(paymentPlanParameter.amountFirst != null) {
                PaymentPlanOption paymentPlanOption = createOption(paymentPlanParameter);
                paymentPlanOptions.add(paymentPlanOption);
                paymentPlanParameter.amountFirst = null;
            }
        }
    }
    private static Boolean isPaidBeforeCourseStartDate(PaymentPlanParameters paymentPlanParameter) {
        return paymentPlanParameter.firstRecurringPaymentDate.addMonths(paymentPlanParameter.monthCount - 1).addDays(MAX_DAYS_BEFORE_PAID) < paymentPlanParameter.courseStartDate;
    }
    @TestVisible
    private static void calculateAmounts(PaymentPlanParameters paymentPlanParameter) {
        if(paymentPlanParameter.courseFee >= MIN_FIRST_AMOUNT + MIN_REC_AMOUNT * paymentPlanParameter.monthCount && paymentPlanParameter.courseFee < MIN_FIRST_AMOUNT * (paymentPlanParameter.monthCount + 1)) {
            paymentPlanParameter.amountFirst = MIN_FIRST_AMOUNT;
        } else
        if(paymentPlanParameter.courseFee >= MIN_FIRST_AMOUNT * (paymentPlanParameter.monthCount + 1)) {
            paymentPlanParameter.amountFirst = paymentPlanParameter.courseFee/(paymentPlanParameter.monthCount + 1);
        }
        if(paymentPlanParameter.amountFirst != null) {
            paymentPlanParameter.amountFirst = paymentPlanParameter.amountFirst.setScale(2, System.RoundingMode.CEILING);
            Decimal amountRest = paymentPlanParameter.courseFee - paymentPlanParameter.amountFirst;
            paymentPlanParameter.amountRecurring = (amountRest/paymentPlanParameter.monthCount).setScale(2, System.RoundingMode.DOWN);
            paymentPlanParameter.amountFirst += (amountRest - paymentPlanParameter.amountRecurring * paymentPlanParameter.monthCount);
        }
    }
    @TestVisible
    private static PaymentPlanOption createOption(PaymentPlanParameters paymentPlanParameter) {
        Date lastPaymentDate = paymentPlanParameter.firstRecurringPaymentDate.addMonths(paymentPlanParameter.monthCount - 1);
        PaymentPlanOption paymentPlanOption = new PaymentPlanOption();
        paymentPlanOption.contactId = paymentPlanParameter.contactId;
        paymentPlanOption.bookingId = paymentPlanParameter.bookingId;
        paymentPlanOption.amountFirst = paymentPlanParameter.amountFirst;
        paymentPlanOption.amountRecurring = paymentPlanParameter.amountRecurring;
        paymentPlanOption.label = createOptionLabel(paymentPlanParameter);
        paymentPlanOption.value = String.valueOf(paymentPlanParameter.monthCount);
        paymentPlanOption.startDate = String.valueOf(paymentPlanParameter.firstRecurringPaymentDate.toStartOfMonth());
        paymentPlanOption.endDate = String.valueOf(lastPaymentDate.toStartOfMonth() + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1);
        return paymentPlanOption;
    }
    private static String createOptionLabel(PaymentPlanParameters paymentPlanParameter) {
        String labelText = '';
        if(paymentPlanParameter.amountFirst == paymentPlanParameter.amountRecurring) {
            String labelTemplate = '{0} monthly payment of £ {1}';
            labelText = String.format(labelTemplate, new List<Object> {paymentPlanParameter.monthCount + 1, paymentPlanParameter.amountRecurring});
        } else {
            String labelTemplate = '1 payment of £ {0} and {1} monthly payment of £ {2}';
            labelText = String.format(labelTemplate, new List<Object> {paymentPlanParameter.amountFirst, paymentPlanParameter.monthCount, paymentPlanParameter.amountRecurring});
        }
        return labelText;
    }
}