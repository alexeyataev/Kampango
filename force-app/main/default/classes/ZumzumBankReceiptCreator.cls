public with sharing class ZumzumBankReceiptCreator implements IBankReceiptCreator {
    private static final Boolean CONTINUE_IF_ERRORS = true;
    public static void createBankReceipts(List<Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper> receiptWrapperList) {
        Zumzum.BankCustomerReceiptService bankCustomerReceiptService = new Zumzum.BankCustomerReceiptService();
        bankCustomerReceiptService.CreateBankCustomerReceipt(receiptWrapperList, CONTINUE_IF_ERRORS);
    }
}
