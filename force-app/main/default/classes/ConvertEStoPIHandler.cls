public with sharing class ConvertEStoPIHandler {
    public static final String CONVERSION_SUBMITTED_SUCCESS = 'Expense Sheet record(s) submitted successfully';
    public static final String CONVERSION_SUBMITTED_ERROR = 'Expense Sheet Ids must be provided';
    public static IExpenseSheetToPurchaseInvoiceConverter expenseSheetToPurchaseInvoiceConverter {
        get {
            if(expenseSheetToPurchaseInvoiceConverter == null) {
                expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverter();
            }
            return expenseSheetToPurchaseInvoiceConverter;
        }
        public set;
    }
    public static zumzum.ExpenseSheetService.Response convertExpenseSheetToPurchaseInvoice(Set<Id> expenseSheetIds) {
        try {

            if (expenseSheetIds == null || expenseSheetIds.isEmpty()) {
                throw new ListException(CONVERSION_SUBMITTED_ERROR);
            }

            zumzum.ExpenseSheetService.Response expenceSheetResult = expenseSheetToPurchaseInvoiceConverter.convert(expenseSheetIds);

            return expenceSheetResult;

        } catch(Exception e) {
            zumzum.ExpenseSheetService.Response expenceSheetErrorResult = new zumzum.ExpenseSheetService.Response();
            expenceSheetErrorResult.ResponseMessage = e.getMessage();

            return expenceSheetErrorResult;
        }
    }
}
