@IsTest
public class TestPurchaseInvoiceBuilder {

	private Id accountId;
	private Id contactId;
	private Date dueDate;
	private Boolean insertRecord = false;
	private Date invoiceDate;
	private Id purchaseOrderId;
	private String status;
	private String type;

	public TestPurchaseInvoiceBuilder withAccount(Id accountId) {
		this.accountId = accountId;
		return this;
	}

	public TestPurchaseInvoiceBuilder withContact(Id contactId) {
		this.contactId = contactId;
		return this;
	}

	public TestPurchaseInvoiceBuilder withInvoiceDate(Date invoiceDate) {
		this.invoiceDate = invoiceDate;
		return this;
	}

	public TestPurchaseInvoiceBuilder withDueDate(Date dueDate) {
		this.dueDate = dueDate;
		return this;
	}

	public TestPurchaseInvoiceBuilder withPurchaseOrder(Id purchaseOrderId) {
		this.purchaseOrderId = purchaseOrderId;
		return this;
	}

	public TestPurchaseInvoiceBuilder withStatus(String status) {
		this.status = status;
		return this;
	}

	public TestPurchaseInvoiceBuilder withType(String type) {
		this.type = type;
		return this;
	}

	public TestPurchaseInvoiceBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Zumzum__Purchase_Invoice__c build(){

		Zumzum__Purchase_Invoice__c testPurchaseInvoice = new Zumzum__Purchase_Invoice__c (
				Zumzum__Account__c = this.accountId,
				Zumzum__Contact__c = this.contactId,
				Zumzum__Invoice_Date__c =this.invoiceDate,
				Zumzum__Invoice_Due_Date__c =  this.dueDate,
				Zumzum__Purchase_Order__c = this.purchaseOrderId,
				Zumzum__Status__c = this.status,
				Zumzum__Type__c = type
		);

		if(insertRecord) {
			insert testPurchaseInvoice;
		}

		return testPurchaseInvoice;
	}
}
