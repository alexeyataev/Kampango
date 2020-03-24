public with sharing class ZumzumBankReceiptCreator implements IBankReceiptCreator {
    public static void createBankReceipt(Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper receiptWrapper) {
        Zumzum.BankCustomerReceiptService bankCustomerReceiptService = new Zumzum.BankCustomerReceiptService();
        bankCustomerReceiptService.CreateBankCustomerReceipt(receiptWrapper);
    }
}
