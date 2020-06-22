@isTest
private class GeneratePaymentFilePaymentRunTest {

	@testSetup
	static void setup(){

		TestAccountBuilder accountBuilder = new TestAccountBuilder();
		Account supplierAccount = accountBuilder.WithRecordType('Organization')
				.withName('Tom Genet')
				.withType('Supplier')
				.withAccountNumber('869344')
				.withBillingEmail('tets@gmail.com')
				.withBankSortCode('572899')
				.withBankAccountNumber('03456123')
				.withBankAccountName('TEST BANK ACCOUNT')
				.insertRecord(true)
				.build();

		TestPurchaseOrderBuilder purchaseOrderBuilder = new TestPurchaseOrderBuilder();
		Zumzum__Purchase_Order__c purchaseOrder = purchaseOrderBuilder
				.withStatus('Approved')
				.withOrderDate(Date.today())
				.withSupplier(supplierAccount.Id)
				.withType('Stock PO')
				.insertRecord(true)
				.build();

		TestProductBuilder productBuilder = new TestProductBuilder();
		Product2 product = productBuilder
				.withName('Doll')
				.insertRecord(true)
				.build();

		TestPurchaseOrderLineItemBuilder purchaseOrderLineItemBuilder = new TestPurchaseOrderLineItemBuilder();
		Zumzum__Purchase_Order_Line_Items__c purchaseOrderLineItems = purchaseOrderLineItemBuilder
				.withAmount(120)
				.withGross(120)
				.withNarrative('Doll')
				.withProduct(product.id)
				.withPurchaseOrder(purchaseOrder.Id)
				.withQuantity(1)
				.insertRecord(true)
				.build();

		TestPurchaseInvoiceBuilder purchaseInvoiceBuilder = new TestPurchaseInvoiceBuilder();
		Zumzum__Purchase_Invoice__c purchaseInvoice = purchaseInvoiceBuilder
				.withPurchaseOrder(purchaseOrder.Id)
				.withStatus('Approved')
				.withAccount(supplierAccount.Id)
				.withDueDate(Date.today().addDays(20))
				.withInvoiceDate(Date.today())
				.insertRecord(true)
				.build();

		TestPurchaseInvoiceLineItemBuilder purchaseInvoiceLineItemBuilder = new TestPurchaseInvoiceLineItemBuilder();
		Zumzum__Purchase_Invoice_Line_Item__c purchaseInvoiceLineItems = purchaseInvoiceLineItemBuilder
				.withAmount(120)
				.withGross(120)
				.withGross(120)
				.withNet(120)
				.withNarrative('Doll')
				.withQuantity(1)
				.withPurchaseInvoice(purchaseInvoice.Id)
				.insertRecord(true)
				.build();

		TestBatchBankPaymentBuilder batchBankPaymentBuilder = new TestBatchBankPaymentBuilder();
		Zumzum__Batch_Bank_Payment__c batchBankPayment = batchBankPaymentBuilder
				.withStatus('Approved')
				.withPaymentType('Bulk list debit')
				.withType('Cash')
				.insertRecord(true)
				.build();


		TestBankPaymentBuilder bankPaymentBuilder = new TestBankPaymentBuilder();
		Zumzum__Bank_Payment__c bankPayment = bankPaymentBuilder
				.withStatus('Approved')
				.withAmount(120)
				.withSupplier(supplierAccount.Id)
				.withBatchBankPayment(batchBankPayment.id)
				.insertRecord(true)
				.build();

		Zumzum__Tax_Rate__c zumzumTaxRate = new Zumzum__Tax_Rate__c(
			Name = 'No VAT',
			Zumzum__Type__c = 'Non-Vatable',
			Zumzum__Active__c = true,
			Zumzum__Tax_Rate__c = 0
		);

		insert zumzumTaxRate;
		
		Payment_Run__c paymentRun = new Payment_Run__c(
			Status__c = 'Ready'
		);
		insert paymentRun;
		
		Zumzum__Bank_Payment_Line_Item__c bankPaymentLineItem = new Zumzum__Bank_Payment_Line_Item__c(
			Zumzum__Amount__c = 100.00,
			Zumzum__Bank_Payment__c = bankPayment.Id,
			Zumzum__Date__c = Date.today(),
			Payment_Run__c = paymentRun.Id,
			Zumzum__Status__c = 'Draft',
			Zumzum__Tax__c = zumzumTaxRate.Id,
			Zumzum__Purchase_Invoice__c = purchaseInvoice.Id
		);
		insert bankPaymentLineItem;
		
	}

	// @isTest
	// static void generatePaymentFileFromPaymentRunGenerated() {
	// 	PageReference paymentFileRef = Page.GeneratePaymentFilePaymentRun;
	// 	Test.setCurrentPage(paymentFileRef);

	// 	Test.startTest();

	// 	Payment_Run__c paymentRun = [
	// 			SELECT Id, Status__c
	// 			FROM Payment_Run__c
	// 			LIMIT 1
	// 	];

	// 	ApexPages.StandardController standardController = new ApexPages.StandardController(paymentRun);
	// 	GeneratePaymentFilePaymentRunExtension generatePaymentFileController = new GeneratePaymentFilePaymentRunExtension(standardController);

	// 	generatePaymentFileController.init();

	// 	String pageContent =  generatePaymentFileController.getPageContent();
	// 	String contentType =  generatePaymentFileController.getContentType();

	// 	System.assert(!generatePaymentFileController.showError);

	// 	Date todaysDate = Date.today();
	// 	String day = String.valueOf(todaysDate.day()).leftPad(2, '0');
	// 	String month = String.valueOf(todaysDate.month()).leftPad(2, '0');
	// 	String fileName = GeneratePaymentFileUtil.FILE_PREFIX + day + month + todaysDate.year() + GeneratePaymentFileUtil.FILE_EXTENSION;

	// 	System.assertEquals(contentType, 'text/plain#' + fileName);
	// 	Test.stopTest();
	// }
	
	// @isTest
	// static void generatePaymentFileFromPaymentRunError() {
	// 	PageReference paymentFileRef = Page.GeneratePaymentFilePaymentRun;
	// 	Test.setCurrentPage(paymentFileRef);

	// 	Test.startTest();

	// 	Payment_Run__c paymentRun = [
	// 			SELECT Id, Status__c
	// 			FROM Payment_Run__c
	// 			LIMIT 1
	// 	];

	// 	paymentRun.Status__c = 'Closed';
	// 	update paymentRun;

	// 	ApexPages.StandardController standardController = new ApexPages.StandardController(paymentRun);
	// 	GeneratePaymentFilePaymentRunExtension generatePaymentFileController = new GeneratePaymentFilePaymentRunExtension(standardController);

	// 	generatePaymentFileController.init();

	// 	String pageContent =  generatePaymentFileController.getPageContent();
	// 	String contentType =  generatePaymentFileController.getContentType();

	// 	System.assert(generatePaymentFileController.showError);
	// 	System.assertEquals(contentType, 'text/html');
	// 	System.assertEquals(pageContent, '');
	// 	Test.stopTest();
	// }
}