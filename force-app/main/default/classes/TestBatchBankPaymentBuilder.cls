@IsTest
public class TestBatchBankPaymentBuilder {

	private Boolean insertRecord = false;
	private String paymentType;
	private String status;
	private String type;

	public TestBatchBankPaymentBuilder withPaymentType(String paymentType) {
		this.paymentType = paymentType;
		return this;
	}

	public TestBatchBankPaymentBuilder withStatus(String status) {
		this.status = status;
		return this;
	}

	public TestBatchBankPaymentBuilder withType(String type) {
		this.type = type;
		return this;
	}


	public TestBatchBankPaymentBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Zumzum__Batch_Bank_Payment__c build(){
		Zumzum__Batch_Bank_Payment__c testBatchBankPayment = new Zumzum__Batch_Bank_Payment__c (
				Zumzum__Type__c = this.type,
				Zumzum__Status__c = this.status,
				Zumzum__Payment_Type__c = this.paymentType);

		if(insertRecord) {
			insert testBatchBankPayment;
		}

		return testBatchBankPayment;
	}

}
