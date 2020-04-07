public with sharing class ZumzumBankReceiptCreator implements IBankReceiptCreator {
    public static void createBankReceipt(List<Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper> receiptWrapperList) {
        Zumzum.BankCustomerReceiptService bankCustomerReceiptService = new Zumzum.BankCustomerReceiptService();
        bankCustomerReceiptService.CreateBankCustomerReceipt(receiptWrapperList);
    }
}
