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
            purchaseCreditLineItem.NominalAccount = financialSettings.PI_Nominal_Account_Id__c;
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
    }

    private static void postPurchaseInvoices(List<Zumzum__Purchase_Invoice__c> invoices) {
        Zumzum.PurchaseInvoiceService postService = new Zumzum.PurchaseInvoiceService();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            Zumzum.PurchaseInvoiceService.Response apiResponse = postService.postPurchaseInvoice(pi.Id);
        }
    }
    
    public class ClaimFeeWrapper {

        @InvocableVariable
        public List<Session__c> sessions;
        
        @InvocableVariable
        public Decimal registrationFee;

    }
    public class CreatePurchaseInvoiceException extends Exception {}
}