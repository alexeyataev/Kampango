@SuppressWarnings('PMD.ApexCRUDViolation')
/** As @SupressWarning annotation cannot be added along with @Invocable one
  * it was decided to add PMD.ApexCRUDViolation annotation to whole class
  * Incident #32 - https://confluence.nct.org.uk:8443/x/EoSO 
*/

public with sharing class ClaimFeeHelper {

    private static final String PURCHASE_INVOICE = 'Purchase Invoice';
    private static final String PURCHASE_CREDIT = 'Purchase Credit';
    private static final String DEFAULT_CURRENCY = 'GBP';
    private static final String PRACTITIONER_TAX_RATE = 'No VAT';
    private static final String API_SUCCESS_MESSAGE = 'Success';
    private static Map<String, String> statusInvoiceMap;

    @InvocableMethod(label='Create Purchase Invoice')
    public static void createPurchaseInvoice(List<ClaimFeeWrapper> flowData) {
        List<Session__c> sessions = flowData[0].sessions;
        
        Financial_Settings__c financialSettings = Financial_Settings__c.getInstance();

        User currentUser = [
            SELECT Name, AccountId, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Currency__c zumzumCurrency = [
            SELECT Id
            FROM Zumzum__Currency__c 
            WHERE Name =: DEFAULT_CURRENCY
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Tax_Rate__c zumzumNoVAT = [
            SELECT Id, Name 
            FROM Zumzum__Tax_Rate__c 
            WHERE Name =: PRACTITIONER_TAX_RATE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Map<String, Id> dimensionsMap = getDimensionsMap();
        
        Zumzum.PurchaseInvoiceService purchaseInvoiceService = new Zumzum.PurchaseInvoiceService();
        List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper> purchases = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper>();
        
        //Purchase Invoice
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseInvoice = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseInvoiceLineItem;

        purchaseInvoice.InvoiceDate = Date.today();
        purchaseInvoice.InvoiceDueDate = Date.today();
        purchaseInvoice.SupplierAccount = currentUser.AccountId;
        purchaseInvoice.TransactionCurrency = zumzumCurrency.Id;
        purchaseInvoice.PurchaseInvoiceType = PURCHASE_INVOICE;
        purchaseInvoice.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();

        for (Session__c session : sessions) {
            purchaseInvoiceLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();
            purchaseInvoiceLineItem.NominalAccount = financialSettings.PI_Nominal_Account_Id__c;
            purchaseInvoiceLineItem.ForeignNetAmount = session.Practitioner_Fees__c;
            purchaseInvoiceLineItem.Quantity = 1;
            purchaseInvoiceLineItem.TaxRate = zumzumNoVAT.Id;
            purchaseInvoiceLineItem.Narrative = 'required field';
            purchaseInvoiceLineItem.WrapperAPICustomFields = new Zumzum.APICustomFieldWrapper[]{
                new Zumzum.APICustomFieldWrapper('Zumzum__Purchase_Invoice_Line_Item__c', 'Session__c', session.Id)
            };
            purchaseInvoiceLineItem.Dimension1 = 
                String.isNotBlank(session.PSA_Area__c) ? dimensionsMap.get(session.PSA_Area__c) : null;
            purchaseInvoiceLineItem.Dimension2 = 
                String.isNotBlank(session.Course__c) ? dimensionsMap.get(session.Course__c) : null;

            purchaseInvoice.LineItems.add(purchaseInvoiceLineItem);
        }
    
        purchases.add(purchaseInvoice);

        //Purchase credit
        Boolean isPurchaseCreditNeeded = flowData[0].registrationFee > 0;
        if (isPurchaseCreditNeeded) {
            Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseCredit = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
            Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseCreditLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();

            purchaseCredit.InvoiceDate = Date.today();
            purchaseCredit.InvoiceDueDate = Date.today();
            purchaseCredit.SupplierAccount = currentUser.AccountId;
            purchaseCredit.TransactionCurrency = zumzumCurrency.Id;
            purchaseCredit.PurchaseInvoiceType = PURCHASE_CREDIT;
            purchaseCredit.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();

            purchaseCreditLineItem.ForeignNetAmount = flowData[0].registrationFee;
            purchaseCreditLineItem.NominalAccount = financialSettings.PC_Nominal_Account_Id__c;
            purchaseCreditLineItem.Quantity = 1;
            purchaseCreditLineItem.TaxRate = zumzumNoVAT.Id;
            purchaseCreditLineItem.Narrative = 'required field';
            purchaseCreditLineItem.WrapperAPICustomFields = new Zumzum.APICustomFieldWrapper[]{
                new Zumzum.APICustomFieldWrapper('Zumzum__Purchase_Invoice_Line_Item__c', 'Practitioner__c', currentUser.ContactId)
            };
            
            purchaseCredit.LineItems.add(purchaseCreditLineItem);
            purchases.add(purchaseCredit);
        }

        Zumzum.PurchaseInvoiceService.Response objResponse = purchaseInvoiceService.createPurchaseInvoices(purchases);

        if (!objResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
            throw new CreatePurchaseInvoiceException(objResponse.ResponseMessage);
        }

        postPurchaseInvoices(objResponse.purchaseInvoices);

        List<Id> invoices = new List<Id>();
        for (Zumzum__Purchase_Invoice__c pi : objResponse.purchaseInvoices) {
            invoices.add(pi.Id);
        } 
        allocateSupplierBalance(invoices);
    }

    private static void postPurchaseInvoices(List<Zumzum__Purchase_Invoice__c> invoices) {
        Zumzum.PurchaseInvoiceService postService = new Zumzum.PurchaseInvoiceService();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            Zumzum.PurchaseInvoiceService.Response apiResponse = postService.postPurchaseInvoice(pi.Id);
            if (!apiResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
                throw new CreatePurchaseInvoiceException(apiResponse.ResponseMessage);
            }
        }
    }

    @future
    private static void allocateSupplierBalance(List<Id> invoiceIds) {
        User currentUser = [
            SELECT Name, AccountId, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];

        Zumzum.BankAllocateCreditsAndPaymentsService paymentService = new Zumzum.BankAllocateCreditsAndPaymentsService();
        Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper allocatedCreditWrapper = 
            new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper();

        allocatedCreditWrapper.AccountId = currentUser.AccountId;
        allocatedCreditWrapper.PostingDate = Date.today();
        
        List<Zumzum__Ledger__c> ledgerRecords = [
            SELECT Id, Name, Zumzum__Net_Amount__c, Zumzum__Purchase_Invoice__r.Zumzum__Type__c, Zumzum__Nominal_Name__c, Zumzum__Nominal__c, Zumzum__Sub_Account_Nominal_Link__c
            FROM Zumzum__Ledger__c
            WHERE Zumzum__Purchase_Invoice__c IN :invoiceIds
                AND Zumzum__Customer_Supplier_Account_Name__c != null
        ];

        List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper> paymentLines = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper>();
        Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper bankLineItem;

        Decimal creditAmount = 0.00;
        for (Zumzum__Ledger__c ledgerRecord : ledgerRecords) {
            if (ledgerRecord.Zumzum__Purchase_Invoice__r.Zumzum__Type__c == PURCHASE_CREDIT) {
                creditAmount = ledgerRecord.Zumzum__Net_Amount__c;
            }
        }
        for (Zumzum__Ledger__c ledgerRecord : ledgerRecords) {
            bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
            bankLineItem.LedgerName = ledgerRecord.Name;
            bankLineItem.Amount = creditAmount;
            paymentLines.add(bankLineItem);
        }
        
        allocatedCreditWrapper.BankAllocateLines = paymentLines;

        Zumzum.BankAllocateCreditsAndPaymentsService.Response objResponse = paymentService.bankAllocateSupplierBalance(allocatedCreditWrapper);
        if (!objResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
            sendEmailToFinance(invoiceIds);
        }
    }

    public static void sendEmailToFinance(List<Id> invoiceIds) {
        if (statusInvoiceMap == null || statusInvoiceMap.isEmpty()) {
            setStatusInvoiceMap(invoiceIds);
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { 'matvey.gutyrko@greencouchconsulting.com' };
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('developer@nct.co.uk');
        mail.setSubject('PI PC failed to match email');
        mail.setPlainTextBody(getLinkingErrorPlainText());
        mail.setHtmlBody(getLinkingErrorHtmlEmailTemplate());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static Map<String, Id> getDimensionsMap() {
        List<Zumzum__Dimension__c> dimensions = [
            SELECT Name, Id
            FROM Zumzum__Dimension__c
            WHERE Zumzum__Active__c = true
        ];

        Map<String, Id> dimensionsMap = new Map<String, Id>();
        for (Zumzum__Dimension__c dimension : dimensions) {
            dimensionsMap.put(dimension.Name, dimension.Id);
        }
        return dimensionsMap;
    }

    private static void setStatusInvoiceMap(List<Id> invoiceIds) {
        List<Zumzum__Purchase_Invoice__c> invoices = [
            SELECT Id, Name, Zumzum__Type__c
            FROM Zumzum__Purchase_Invoice__c
            WHERE Id IN :invoiceIds
            WITH SECURITY_ENFORCED
        ];
        statusInvoiceMap =  new Map<String, String>();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            if (pi.Zumzum__Type__c == PURCHASE_CREDIT) {
                statusInvoiceMap.put(PURCHASE_CREDIT, pi.Name);
            } else {
                statusInvoiceMap.put(PURCHASE_INVOICE, pi.Name);
            }
        }
    }

    private static String getLinkingErrorHtmlEmailTemplate() {
        String htmlTemplate = 'Dear Finance, <br><br>' + 
            'The following invoices and credit notes have been created but have failed to be matched. ' +
            'Please manually match the PI and PC to avoid overpayment to the practitioner before ' +
            'payment run is made. <br><br>' +
            'PI ' + statusInvoiceMap.get(PURCHASE_INVOICE) +
            '<br>' +
            'PC ' + statusInvoiceMap.get(PURCHASE_CREDIT) +
            '<br><br> Kind regards, <br> NCT';
        return htmlTemplate;
    }
    
    private static String getLinkingErrorPlainText() {
        String plainText = 'Please manually match the PI and PC to avoid overpayment to the practitioner before ' +
            'payment run is made. ' +
            'PI ' + statusInvoiceMap.get(PURCHASE_INVOICE) +
            '<br>' +
            ' PC ' + statusInvoiceMap.get(PURCHASE_CREDIT);
        return plainText;
    }
    
    public class ClaimFeeWrapper {

        @InvocableVariable
        public List<Session__c> sessions;
        
        @InvocableVariable
        public Decimal registrationFee;

    }
    public class CreatePurchaseInvoiceException extends Exception {}
}