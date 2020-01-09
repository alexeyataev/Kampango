public with sharing class PaymentPlanGenerator {
    @TestVisible private static IClock clock = new SystemClock();
    private static final Integer MAX_DAYS_BEFORE_PAID = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Min_Days_Fully_Paid_Before_Course_Start__c);
    private static final Integer MAX_RECURRING_INSTALLMENTS_NUMBER = 3;
    private static final Integer MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Min_Days_Before_First_Recurring_Payment__c);
    private static final Decimal MIN_FIRST_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimum_First_Amount__c;
    private static final Decimal MIN_REC_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimum_Recurring_Amount__c;
    public static List<PaymentPlanOption> getOptions(Decimal courseFee, Date courseStartDate) {
        Date firstRecurringPaymentDate = getFirstRecurringPaymentDate();
        List<PaymentPlanOption> paymentPlanOptions = new List<PaymentPlanOption>();
        for(Integer numberOfPayments = 1; numberOfPayments <= MAX_RECURRING_INSTALLMENTS_NUMBER; numberOfPayments++) {
            if(isPaidBeforeCourseStartDate(numberOfPayments, courseStartDate, firstRecurringPaymentDate)) {
                PaymentPlanOption paymentPlanOption = calculateAmounts(courseFee, numberOfPayments);
                if(paymentPlanOption != null) {
                    Date lastPaymentDate = firstRecurringPaymentDate.addMonths(numberOfPayments - 1);
                    paymentPlanOption.startDate = firstRecurringPaymentDate.toStartOfMonth();
                    paymentPlanOption.endDate = lastPaymentDate.toStartOfMonth() + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1;
                    paymentPlanOption.displayLabel = createOptionLabel(paymentPlanOption, numberOfPayments);
                    paymentPlanOption.numberOfPayments = String.valueOf(numberOfPayments);
                    paymentPlanOptions.add(paymentPlanOption);
                }
            }
        }
        return paymentPlanOptions;
    }
    private static Date getFirstRecurringPaymentDate() {
        Date firstRecurringPaymentDate;
        Date initialPaymentDate = clock.today();
        Integer daysInCurrentMonth = Date.daysInMonth(initialPaymentDate.year(), initialPaymentDate.month());
        Integer daysToday = initialPaymentDate.day();
        firstRecurringPaymentDate = initialPaymentDate.addMonths(1).toStartOfMonth();
        if(daysInCurrentMonth - daysToday <= MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT) {
            firstRecurringPaymentDate = firstRecurringPaymentDate.addMonths(1);
        }
        return firstRecurringPaymentDate;
    }
    private static Boolean isPaidBeforeCourseStartDate(Integer numberOfRecurringPayments, Date courseStartDate, Date firstRecurringPaymentDate) {
        return firstRecurringPaymentDate.addMonths(numberOfRecurringPayments - 1).addDays(MAX_DAYS_BEFORE_PAID) < courseStartDate;
    }
    @TestVisible
    private static PaymentPlanOption calculateAmounts(Decimal courseFee, Integer numberOfRecurringPayments) {
        PaymentPlanOption paymentPlanOption = new PaymentPlanOption();
        if(courseFee >= MIN_FIRST_AMOUNT + MIN_REC_AMOUNT * numberOfRecurringPayments && courseFee < MIN_FIRST_AMOUNT * (numberOfRecurringPayments + 1)) {
            paymentPlanOption.amountFirst = MIN_FIRST_AMOUNT;
        } else
        if(courseFee >= MIN_FIRST_AMOUNT * (numberOfRecurringPayments + 1)) {
            paymentPlanOption.amountFirst = courseFee/(numberOfRecurringPayments + 1);
        } else {
            return null;
        }
        paymentPlanOption.amountFirst = paymentPlanOption.amountFirst.setScale(2, System.RoundingMode.CEILING);
        Decimal amountRest = courseFee - paymentPlanOption.amountFirst;
        paymentPlanOption.amountRecurring = (amountRest/numberOfRecurringPayments).setScale(2, System.RoundingMode.DOWN);
        paymentPlanOption.amountFirst += (amountRest - paymentPlanOption.amountRecurring * numberOfRecurringPayments);
        return paymentPlanOption;
    }
    private static String createOptionLabel(PaymentPlanOption paymentPlanOption, Integer numberOfRecurringPayments) {
        String labelText;
        if(paymentPlanOption.amountFirst == paymentPlanOption.amountRecurring) {
            String labelTemplate = Label.Payment_Plan_Equal_Amounts_Option_Template;
            labelText = String.format(labelTemplate, new List<Object> {numberOfRecurringPayments + 1, paymentPlanOption.amountRecurring});
        } else 
        if(numberOfRecurringPayments == 1) {
            String labelTemplate = Label.Payment_Plan_Different_Amounts_Option_Template;
            labelText = String.format(labelTemplate, new List<Object> {paymentPlanOption.amountFirst, numberOfRecurringPayments, paymentPlanOption.amountRecurring});
        } else {
            String labelTemplate = Label.Payment_Plan_Different_Multiple_Amounts_Option_Template;
            labelText = String.format(labelTemplate, new List<Object> {paymentPlanOption.amountFirst, numberOfRecurringPayments, paymentPlanOption.amountRecurring});
        }
        return labelText;
    }
}