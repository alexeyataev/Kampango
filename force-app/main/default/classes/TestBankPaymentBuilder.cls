@IsTest
public class TestBankPaymentBuilder {

	private Double amount;
	private Id batchBankPaymentId;
	private Boolean insertRecord = false;
	private String status;
	private Id supplierId;

	public TestBankPaymentBuilder withAmount(Double amount) {
		this.amount = amount;
		return this;
	}

	public TestBankPaymentBuilder withBatchBankPayment(Id batchBankPaymentId) {
		this.batchBankPaymentId = batchBankPaymentId;
		return this;
	}

	public TestBankPaymentBuilder withStatus(String status) {
		this.status = status;
		return this;
	}

	public TestBankPaymentBuilder withSupplier(Id supplierId) {
		this.supplierId = supplierId;
		return this;
	}

	public TestBankPaymentBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Zumzum__Bank_Payment__c build(){
		Zumzum__Bank_Payment__c testBankPayment = new Zumzum__Bank_Payment__c(
				Zumzum__Supplier__c = this.supplierId,
				Zumzum__Amount__c = this.amount,
				Zumzum__Status__c = this.status,
				Zumzum__Batch_Bank_Payment__c = this.batchBankPaymentId
		);

		if(insertRecord) {
			insert testBankPayment;
		}

		return testBankPayment;
	}
}
