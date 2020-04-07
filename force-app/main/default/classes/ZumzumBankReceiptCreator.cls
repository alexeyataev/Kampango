public with sharing class ZumzumBankReceiptCreator implements IBankReceiptCreator {
    public static void createBankReceipts(List<Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper> receiptWrapperList) {
        Zumzum.BankCustomerReceiptService bankCustomerReceiptService = new Zumzum.BankCustomerReceiptService();
        bankCustomerReceiptService.CreateBankCustomerReceipt(receiptWrapperList);
    }
}
