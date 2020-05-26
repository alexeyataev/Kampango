public with sharing class ConvertEStoPIHandler {
    public static final String CONVERTION_SUBMITTED_SUCCESS = 'Expense Sheet record(s) submitted successfully';
    public static final String CONVERTION_SUBMITTED_ERROR = 'Expense Sheet Ids must be provided';
    public static IExpenseSheetToPurchaseInvoiceConverter expenseSheetToPurchaseInvoiceConverter {
        get {
            if(expenseSheetToPurchaseInvoiceConverter == null) {
                expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverter();
            }
            return expenseSheetToPurchaseInvoiceConverter;
        }
        public set;
    }
    public static String convertExpenseSheetToPurchaseInvoice(Set<Id> expenseSheetIds) {
        try {
            if(expenseSheetIds == null || expenseSheetIds.isEmpty()) {
                throw new ListException(CONVERTION_SUBMITTED_ERROR);
            }
            expenseSheetToPurchaseInvoiceConverter.convert(expenseSheetIds);
            return CONVERTION_SUBMITTED_SUCCESS;
        } catch(Exception e) {
            return e.getMessage();
        }
    }
}
