public with sharing class PaymentPlanOptionsHandler {
    private static Id bookingId;
    private static Id contactId;
    private static Decimal courseFee;
    private static final Integer DAYS_BEFORE_NEXT_MONTH = 14;
    private static Date lastPaymentDate;
    private static final Integer MAX_DAYS_BEFORE_PAID = Integer.valueOf(Card_Payment_Plan_Settings__c.getOrgDefaults().Maximum_Days_Before_Paid__c);
    private static final Integer MAX_OPTIONS_AMOUNT = 3;
    private static final Decimal MIN_FIRST_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimal_First_Amount__c;
    private static final Decimal MIN_REC_AMOUNT = Card_Payment_Plan_Settings__c.getOrgDefaults().Minimal_Recurring_Amount__c;
    private static final Date secondInstallmentDate = getSecondInstallmentDate();
    @InvocableMethod
    public static List<List<PaymentPlanOption>> getOptions(List<PaymentPlanParam> paymentPlanParams) {
        bookingId = paymentPlanParams[0].bookingId;
        contactId = paymentPlanParams[0].contactId;
        courseFee = paymentPlanParams[0].courseFee;
        lastPaymentDate = paymentPlanParams[0].startDate;
        List<PaymentPlanOption> options = getOptions();
        return new List<List<PaymentPlanOption>> {options};
    }
    private static List<PaymentPlanOption> getOptions() {
        List<PaymentPlanOption> paymentPlanOptions = new List<PaymentPlanOption>();
        for(Integer i = 1; i <= MAX_OPTIONS_AMOUNT; i++) {
            addOption(paymentPlanOptions, i);
        }
        return paymentPlanOptions;
    }
    private static Date getSecondInstallmentDate() {
        Date firstPaymentDate = Date.today();
        Date secondInstallmentDate;
        Integer daysInCurrentMonth = Date.daysInMonth(firstPaymentDate.year(), firstPaymentDate.month());
        Integer daysToday = firstPaymentDate.day();
        secondInstallmentDate = firstPaymentDate.addDays(daysInCurrentMonth - daysToday + 1);
        if(daysInCurrentMonth - daysToday <= DAYS_BEFORE_NEXT_MONTH) {
            secondInstallmentDate = secondInstallmentDate.addMonths(1);
        }
        return secondInstallmentDate;
    }
    private static void addOption(List<PaymentPlanOption> paymentPlanOptions, Integer monthCount) {
        if(secondInstallmentDate.addMonths(monthCount - 1).addDays(MAX_DAYS_BEFORE_PAID) < lastPaymentDate) {
            Decimal firstAmount;
            if(courseFee >= MIN_FIRST_AMOUNT + MIN_REC_AMOUNT * monthCount && courseFee < MIN_FIRST_AMOUNT * (monthCount + 1)) {
                firstAmount = MIN_FIRST_AMOUNT;
            } else
            if(courseFee >= MIN_FIRST_AMOUNT * (monthCount + 1)) {
                firstAmount = courseFee/(monthCount + 1);
            }
            if(firstAmount != null) {
                PaymentPlanOption paymentPlanOption = createOption(courseFee, firstAmount, monthCount);
                paymentPlanOptions.add(paymentPlanOption);
            }
        }
    }
    private static String createOptionLabel(Decimal amountFirst, Decimal amountRecurring, Integer numberRecInstallment) {
        String labelText = '';
        if(amountFirst == amountRecurring) {
            labelText = numberRecInstallment + 1 + ' monthly payment of £ ' + amountRecurring;
        } else {
            labelText = '1 payment of £ ' + amountFirst + ' and ' + numberRecInstallment + ' monthly payment of £ ' + amountRecurring;
        }
        return labelText;
    }
    private static PaymentPlanOption createOption(Decimal courseFee, Decimal amountFirst, Integer numberRecInstallment) {
        amountFirst = amountFirst.setScale(2, System.RoundingMode.CEILING);
        Decimal amountRest = courseFee - amountFirst;
        Decimal amountRecInstallment = (amountRest/numberRecInstallment).setScale(2, System.RoundingMode.DOWN);
        amountFirst += (amountRest - amountRecInstallment * numberRecInstallment);
        PaymentPlanOption paymentPlanOption = new PaymentPlanOption();
        paymentPlanOption.contactId = contactId;
        paymentPlanOption.bookingId = bookingId;
        paymentPlanOption.amountFirst = amountFirst;
        paymentPlanOption.amountRecurring = amountRecInstallment;
        paymentPlanOption.label = createOptionLabel(paymentPlanOption.amountFirst, paymentPlanOption.amountRecurring, numberRecInstallment);
        paymentPlanOption.value = String.valueOf(numberRecInstallment);
        paymentPlanOption.startDate = String.valueOf(secondInstallmentDate.toStartOfMonth());
        paymentPlanOption.endDate = String.valueOf(lastPaymentDate.toStartOfMonth() + Date.daysInMonth(lastPaymentDate.year(), lastPaymentDate.month()) - 1);
        return paymentPlanOption;
    }
}