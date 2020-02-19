public with sharing class ZumzumCreatePostSalesInvoice {
    public static ISalesInvoiceCreator salesInvoiceCreator {
        get {
            if(salesInvoiceCreator == null) {
                salesInvoiceCreator = new ZumzumSalesInvoiceCreator();
            }
            return salesInvoiceCreator;
        }
        public set;
    }
    @InvocableMethod
    public static List<Zumzum__Sales_Invoice__c> createSI(List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameterList) {
        try {
            List<ZumzumSalesInvoiceParameters> zumzumSalesInvoiceParameters = zumzumSalesInvoiceParameterList[0];
            List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper> newSalesInvoiceDataList = new List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper>();
            Zumzum.SalesInvoicePostService.SalesInvoiceWrapper salesInvoice = new Zumzum.SalesInvoicePostService.SalesInvoiceWrapper( );
            salesInvoice.LineItems = new List<Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper>();
            for(ZumzumSalesInvoiceParameters zumzumSalesInvoiceParameter : zumzumSalesInvoiceParameters) {
                salesInvoice.Customer = salesInvoice.Customer == null ? zumzumSalesInvoiceParameter.customerId : salesInvoice.Customer; //Zumzum__Account__c
                salesInvoice.InvoiceDate = Date.today(); //Zumzum__Invoice_Date__c
                salesInvoice.TransactionCurrency = salesInvoice.TransactionCurrency == null ? zumzumSalesInvoiceParameter.transactionCurrencyId : salesInvoice.TransactionCurrency; //Zumzum__Transaction_Currency__c
                
                if(salesInvoice.WrapperAPICustomFields == null) {
                    salesInvoice.WrapperAPICustomFields = new List<Zumzum.APICustomFieldWrapper>();
                    salesInvoice.WrapperAPICustomFields.add(new Zumzum.APICustomFieldWrapper('Zumzum__Sales_Invoice__c','Booking__c', zumzumSalesInvoiceParameter.bookingId)); 
                }
                
                Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper salesInvoiceLine = new Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper();
                salesInvoiceLine.Product = zumzumSalesInvoiceParameter.productId; //Zumzum__Product__c
                salesInvoiceLine.NominalAccount = zumzumSalesInvoiceParameter.nominalAccountId; //Zumzum__Nominal_Account__c
                salesInvoiceLine.Quantity = 1; //Zumzum__Quantity__c
                salesInvoiceLine.TaxRate = zumzumSalesInvoiceParameter.taxRateId; //Zumzum__Tax_Rate__c
                salesInvoiceLine.ForeignNetAmount = zumzumSalesInvoiceParameter.foreignNetAmount; //Zumzum__Foreign_Net_Amount__c
                salesInvoiceLine.Dimension1 = zumzumSalesInvoiceParameter.dimension1Id; //Zumzum__Dimension_1__c
                salesInvoiceLine.Dimension2 = zumzumSalesInvoiceParameter.dimension2Id; //Zumzum__Dimension_2__c
                salesInvoice.LineItems.add(salesInvoiceLine);
            }
            newSalesInvoiceDataList.add(salesInvoice);
            List<Zumzum__Sales_Invoice__c> newSalesInvoices = salesInvoiceCreator.createSI(newSalesInvoiceDataList);
            salesInvoiceCreator.postSI(newSalesInvoices);
            return newSalesInvoices;
        } catch(Exception e) {
            return null;
        }
    }
}