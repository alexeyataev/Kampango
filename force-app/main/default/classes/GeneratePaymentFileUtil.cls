@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #11 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class GeneratePaymentFileUtil {

    public static final String FILE_PREFIX = PaymentFileSettings__c.getInstance(UserInfo.getProfileId()).PSA_File_Prefix__c;
    public static final String FILE_EXTENSION = PaymentFileSettings__c.getInstance(UserInfo.getProfileId()).PSA_File_Extension__c;

    private class BankPaymentWrapper {
        public List<String> columns;
        private Zumzum__Bank_Payment__c bankPayment;

        public BankPaymentWrapper(Zumzum__Bank_Payment__c bankPayment) {
            this.bankPayment = bankPayment;
            this.columns = new List<String>();
        }

        public List<String> getColumns(String purchaseInvoiceName) {
            this.columns.add(bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c);
            this.columns.add(bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Account_No__c);
            this.columns.add(this.getPaymentAmount());
            this.columns.add(this.getBankAccountName());
            this.columns.add(this.getPaymentReference(purchaseInvoiceName));

            return this.columns;
        }

        private String getPaymentAmount() {
            String amount = String.valueOf(bankPayment.Zumzum__Amount__c);
            return amount.leftPad(11, '0');
        }

        private String getBankAccountName() {
            String formatedAccountName = String.isBlank(bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c)
                                       ? ''
                                       : bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c;

            return formatedAccountName.rightPad(18, '');
        }

        private String getPaymentReference(String purchaseInvoiceName) {
            purchaseInvoiceName = 'NCT/' + purchaseInvoiceName;

            return purchaseInvoiceName.rightPad(18, ' ');
        }
    }

    //Need to deleted adter success deploy
    public static String generatePaymentFileContent(String Id) {
        return '';
    }

    public static String generatePaymentFileContent(Payment_Run__c paymentRun) {
        List<Zumzum__Bank_Payment__c> bankPayments = getPayments(paymentRun);

        String[] rows = new String[bankPayments.size()];

        for (Zumzum__Bank_Payment__c bankPayment: bankPayments) {
            BankPaymentWrapper bankPaymentWrapper = new BankPaymentWrapper(bankPayment);
            rows.add(
                String.join(
                    bankPaymentWrapper.getColumns(bankPayment.Zumzum__Bank_Payment_Line_Items__r[0].Zumzum__Purchase_Invoice__r.Name), ' '
                ).trim()
            );
        }

        String result = String.join(rows,'\r\n').trim();

        return result;
    }

    public static String generatePaymentFileName() {
        Date currentDate = Date.today();
        String day = String.valueOf(currentDate.day()).leftPad(2, '0');
        String month = String.valueOf(currentDate.month()).leftPad(2, '0');
        String fileName = FILE_PREFIX + day + month + currentDate.year() + FILE_EXTENSION;
        return fileName;
    }

    private static List<Zumzum__Bank_Payment__c> getPayments(Payment_Run__c paymentRun) {
        Set<Id> bankPaymentIds = new Set<Id>();

        if (paymentRun != null) {
            for (Zumzum__Bank_Payment_Line_Item__c lineItem : paymentRun.Bank_Payment_Line_Items__r) {
                bankPaymentIds.add(lineItem.Zumzum__Bank_Payment__c);
            }
        }

        List<Zumzum__Bank_Payment__c> payments = [
            SELECT Id,
                   Name,
                   Zumzum__Amount__c,
                   Payment_Reference__c,
                   Zumzum__Supplier__r.PSA_Area__c,
                   Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c,
                   Zumzum__Supplier__r.Zumzum__Bank_Account_No__c,
                   Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c,

                    (
                        SELECT Id, Zumzum__Purchase_Invoice__r.Name
                        FROM Zumzum__Bank_Payment_Line_Items__r
                    )

            FROM Zumzum__Bank_Payment__c
            WHERE Id IN :bankPaymentIds
        ];

        return payments;
    }

}