@IsTest
private class GeneratePaymentFileExtensionTest {

	@TestSetup
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
	}

	@IsTest
	public static void generatePaymentFileBankPaymentApprovedFileGenerated() {

		PageReference paymentFileRef = Page.GeneratePaymentFile;
		Test.setCurrentPage(paymentFileRef);

		Test.startTest();

		Zumzum__Batch_Bank_Payment__c batchBankPayment = [
				SELECT Id
				FROM Zumzum__Batch_Bank_Payment__c
				LIMIT 1
		];

		ApexPages.StandardController standardController = new ApexPages.StandardController(batchBankPayment);
		GeneratePaymentFileExtension generatePaymentFileController = new GeneratePaymentFileExtension(standardController);

		generatePaymentFileController.init();

		String pageContent =  generatePaymentFileController.getPageContent();
		String contentType =  generatePaymentFileController.getContentType();

		System.assert(!generatePaymentFileController.showError);

		Date todaysDate = Date.today();
		String day = String.valueOf(todaysDate.day()).leftPad(2, '0');
		String month = String.valueOf(todaysDate.month()).leftPad(2, '0');
		String fileName = GeneratePaymentFileUtil.FILE_PREFIX + day + month + todaysDate.year() + GeneratePaymentFileUtil.FILE_EXTENSION;

		System.assertEquals(contentType, 'text/plain#' + fileName);

		List<Zumzum__Bank_Payment__c> payments =  [
				SELECT Id,
						Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c,
						Zumzum__Supplier__r.Zumzum__Bank_Account_No__c,
						Zumzum__Amount__c,
						Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c,
						Name,
						Zumzum__Supplier__r.PSA_Area__c,
						Payment_Reference__c
				FROM Zumzum__Bank_Payment__c
				WHERE Zumzum__Batch_Bank_Payment__c = :batchBankPayment.id];


		String[] rows = new String[payments.size()];

		for(Zumzum__Bank_Payment__c payment: payments){
			String[] columns = new String[5];
			columns.add(payment.Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c);
			columns.add(payment.Zumzum__Supplier__r.Zumzum__Bank_Account_No__c);
			columns.add(String.valueOf(payment.Zumzum__Amount__c).leftPad(11, '0'));
			columns.add(payment.Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c.rightPad(18, ' '));
			columns.add(payment.Payment_Reference__c.rightPad(18, ' '));
			String lineStr = String.join(columns, ' ').trim();
			rows.add(lineStr);
		}
		String txtString = String.join(rows,'\n').trim();

		System.assertEquals(pageContent, txtString);

		Test.stopTest();

	}

	@IsTest
	public static void generatePaymentFileBankPaymentNotApprovedShowErrorMessage() {

		PageReference paymentFileRef = Page.GeneratePaymentFile;
		Test.setCurrentPage(paymentFileRef);

		Test.startTest();

		Zumzum__Batch_Bank_Payment__c batchBankPayment = [
				SELECT Id, Zumzum__Status__c
				FROM Zumzum__Batch_Bank_Payment__c
				LIMIT 1
		];

		batchBankPayment.Zumzum__Status__c = 'Draft';

		update batchBankPayment;

		ApexPages.StandardController standardController = new ApexPages.StandardController(batchBankPayment);
		GeneratePaymentFileExtension generatePaymentFileController = new GeneratePaymentFileExtension(standardController);

		generatePaymentFileController.init();

		String pageContent =  generatePaymentFileController.getPageContent();
		String contentType =  generatePaymentFileController.getContentType();

		System.assert(generatePaymentFileController.showError);
		System.assertEquals(contentType, 'text/html');
		System.assertEquals(pageContent, '');

		Test.stopTest();
	}
}
