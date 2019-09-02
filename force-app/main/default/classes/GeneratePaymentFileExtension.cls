public with sharing class GeneratePaymentFileExtension {

	public Boolean showError { get; set;}
	public String txtString;
	public String cntType;

	private Id recordId ;
	private static final String VALID_BATCH_BANK_PAYMENT_STATUS = 'Approved';
	private static final String INVALID_STATUS_MESSAGE = 'Batch Bank Payment should be approved to generate Payment File.';
	private static final String TXT_CONTENT_TYPE = 'text/plain#';
	private static final String HTML_CONTENT_TYPE = 'text/html';

	public GeneratePaymentFileExtension(ApexPages.StandardController stdController){
		this.recordId = stdController.getId();
	}

	public void init(){
		Zumzum__Batch_Bank_Payment__c batchBankPayment = [
				SELECT id, Zumzum__Status__c
				FROM Zumzum__Batch_Bank_Payment__c
				WHERE id = :this.recordId
		];

		this.showError = batchBankPayment.Zumzum__Status__c != VALID_BATCH_BANK_PAYMENT_STATUS;

		if(this.showError) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, INVALID_STATUS_MESSAGE));
		}
	}

	public String getTxtString(){
		return this.showError ? '' : GeneratePaymentFileUtil.generateTxtString(this.recordId);
	}

	public String getCntType(){
		return this.showError ? HTML_CONTENT_TYPE : TXT_CONTENT_TYPE + GeneratePaymentFileUtil.generateTXTFileName();
	}

}