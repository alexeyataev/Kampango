public with sharing class ConvertEStoPIHandler {
    public static IExpenseSheetToPurchaseInvoiceConverter expenseSheetToPurchaseInvoiceConverter {
        get {
            if(expenseSheetToPurchaseInvoiceConverter == null) {
                expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverter();
            }
            return expenseSheetToPurchaseInvoiceConverter;
        }
        public set;
    }
    public static void convertExpenseSheetToPurchaseInvoice(Set<Id> expenseSheetIds) {
        expenseSheetToPurchaseInvoiceConverter.convert(expenseSheetIds);
    }
}
