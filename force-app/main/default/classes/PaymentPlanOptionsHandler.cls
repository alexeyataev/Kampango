public with sharing class PaymentPlanOptionsHandler {
    private static Decimal amountFirst;
    private static Decimal amountRecInstallment;
    private static Id bookingId;
    private static Id contactId;
    private static Decimal courseFee;
    private static Date courseStartDate;
    @TestVisible private static Date firstPaymentDate = Date.today();
    private static Date lastPaymentDate;
    private static final Integer MAX_DAYS_BEFORE_PAID = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Maximum_Days_Before_Paid__c);
    private static final Integer MAX_RECURRING_INSTALLMENTS_NUMBER = 3;
    private static final Integer MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Min_Days_Before_First_Recurring_Payment__c);
    private static final Decimal MIN_FIRST_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimal_First_Amount__c;
    private static final Decimal MIN_REC_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimal_Recurring_Amount__c;
    private static Date secondInstallmentDate;
    @InvocableMethod
    public static List<List<PaymentPlanOption>> getOptions(List<PaymentPlanParameters> paymentPlanParameters) {
        secondInstallmentDate = getSecondInstallmentDate();
        bookingId = paymentPlanParameters[0].bookingId;
        contactId = paymentPlanParameters[0].contactId;
        courseFee = paymentPlanParameters[0].courseFee;
        courseStartDate = paymentPlanParameters[0].startDate;
        List<PaymentPlanOption> options = getOptions();
        return new List<List<PaymentPlanOption>> {options};
    }
    private static List<PaymentPlanOption> getOptions() {
        List<PaymentPlanOption> paymentPlanOptions = new List<PaymentPlanOption>();
        for(Integer i = 1; i <= MAX_RECURRING_INSTALLMENTS_NUMBER; i++) {
            addOption(paymentPlanOptions, i);
        }
        for(PaymentPlanOption paymentPlanOption : paymentPlanOptions) {
            lastPaymentDate = secondInstallmentDate.addMonths(paymentPlanOptions.size() - 1);
            paymentPlanOption.endDate = String.valueOf(lastPaymentDate + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1);
        }
        return paymentPlanOptions;
    }
    private static Date getSecondInstallmentDate() {
        Date secondInstallmentDate;
        Integer daysInCurrentMonth = Date.daysInMonth(firstPaymentDate.year(), firstPaymentDate.month());
        Integer daysToday = firstPaymentDate.day();
        secondInstallmentDate = firstPaymentDate.addDays(daysInCurrentMonth - daysToday + 1);
        if(daysInCurrentMonth - daysToday <= MIN_DAYS_BEFORE_FIRST_RECURRING_PAYMENT) {
            secondInstallmentDate = secondInstallmentDate.addMonths(1);
        }
        return secondInstallmentDate;
    }
    private static void addOption(List<PaymentPlanOption> paymentPlanOptions, Integer monthCount) {
        if(secondInstallmentDate.addMonths(monthCount - 1).addDays(MAX_DAYS_BEFORE_PAID) < courseStartDate) {
            calculateAmounts(monthCount);
            if(amountFirst != null) {
                PaymentPlanOption paymentPlanOption = createOption(monthCount);
                paymentPlanOptions.add(paymentPlanOption);
                amountFirst = null;
            }
        }
    }
    @TestVisible
    private static void calculateAmounts(Integer monthCount) {
        if(courseFee >= MIN_FIRST_AMOUNT + MIN_REC_AMOUNT * monthCount && courseFee < MIN_FIRST_AMOUNT * (monthCount + 1)) {
            amountFirst = MIN_FIRST_AMOUNT;
        } else
        if(courseFee >= MIN_FIRST_AMOUNT * (monthCount + 1)) {
            amountFirst = courseFee/(monthCount + 1);
        }
        if(amountFirst != null) {
            amountFirst = amountFirst.setScale(2, System.RoundingMode.CEILING);
            Decimal amountRest = courseFee - amountFirst;
            amountRecInstallment = (amountRest/monthCount).setScale(2, System.RoundingMode.DOWN);
            amountFirst += (amountRest - amountRecInstallment * monthCount);
        }
    }
    @TestVisible
    private static PaymentPlanOption createOption(Integer monthCount) {
        PaymentPlanOption paymentPlanOption = new PaymentPlanOption();
        paymentPlanOption.contactId = contactId;
        paymentPlanOption.bookingId = bookingId;
        paymentPlanOption.amountFirst = amountFirst;
        paymentPlanOption.amountRecurring = amountRecInstallment;
        paymentPlanOption.label = createOptionLabel(paymentPlanOption.amountFirst, paymentPlanOption.amountRecurring, monthCount);
        paymentPlanOption.value = String.valueOf(monthCount);
        paymentPlanOption.startDate = String.valueOf(secondInstallmentDate.toStartOfMonth());
        return paymentPlanOption;
    }
    private static String createOptionLabel(Decimal amountFirst, Decimal amountRecurring, Integer monthCount) {
        String labelText = '';
        if(amountFirst == amountRecurring) {
            String labelTemplate = '{0} monthly payment of £ {1}';
            labelText = String.format(labelTemplate, new List<Object> {monthCount + 1, amountRecurring});
        } else {
            String labelTemplate = '1 payment of £ {0} and {1} monthly payment of £ {2}';
            labelText = String.format(labelTemplate, new List<Object> {amountFirst, monthCount, amountRecurring});
        }
        return labelText;
    }
}