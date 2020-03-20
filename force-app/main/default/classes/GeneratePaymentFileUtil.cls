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

		public List<String> getColumns(){
			this.columns.add(bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c);
			this.columns.add(bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Account_No__c);
			this.columns.add(this.getPaymentAmount());
			this.columns.add(this.getBankAccountName());
			this.columns.add(this.getPaymentReference());

			return this.columns;
		}

		private String getPaymentAmount(){
			String amount = String.valueOf(bankPayment.Zumzum__Amount__c);
			return amount.leftPad(11, '0');
		}

		private String getBankAccountName(){
			String formatedAccountName = String.isBlank(bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c) ? '' : bankPayment.Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c;
			return formatedAccountName.rightPad(18, '');
		}

		private String getPaymentReference(){
			return bankPayment.Payment_Reference__c.rightPad(18, ' ');
		}
	}

	public static String generatePaymentFileContent(String batchBankPaymentId){
		List<Zumzum__Bank_Payment__c> bankPayments = getPayments(batchBankPaymentId);

		String[] rows = new String[bankPayments.size()];

		for(Zumzum__Bank_Payment__c bankPayment: bankPayments) {
			BankPaymentWrapper bankPaymentWrapper = new BankPaymentWrapper(bankPayment);
			rows.add(String.join(bankPaymentWrapper.getColumns(), ' ').trim());
		}
		String result = String.join(rows,'\r\n').trim();
		return result;
	}
	
	public static String generatePaymentFileContent(Payment_Run__c paymentRun){
		List<Zumzum__Bank_Payment__c> bankPayments = getPayments(paymentRun);

		String[] rows = new String[bankPayments.size()];

		for(Zumzum__Bank_Payment__c bankPayment: bankPayments){
			BankPaymentWrapper bankPaymentWrapper = new BankPaymentWrapper(bankPayment);
			System.debug('bankPaymentWrapper ' + bankPaymentWrapper);
			rows.add(String.join(bankPaymentWrapper.getColumns(), ' ').trim());
		}
		String result = String.join(rows,'\r\n').trim();
		System.debug('generatePaymentFileContent result ' + result);
		return result;
	}

	public static String generatePaymentFileName(){
		Date currentDate = Date.today();
		String day = String.valueOf(currentDate.day()).leftPad(2, '0');
		String month = String.valueOf(currentDate.month()).leftPad(2, '0');
		String fileName = FILE_PREFIX + day + month + currentDate.year() + FILE_EXTENSION;
		return fileName;
	}

	private static List<Zumzum__Bank_Payment__c> getPayments(String batchBankPaymentId){

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
				WHERE Zumzum__Batch_Bank_Payment__c = :batchBankPaymentId
				WITH SECURITY_ENFORCED
		]; 

		return payments;
	}
	
	private static List<Zumzum__Bank_Payment__c> getPayments(Payment_Run__c paymentRun) {
		Set<Id> bankPaymentIds = new Set<Id>();
		if (paymentRun != null) {
			for (Zumzum__Bank_Payment_Line_Item__c lineItem : paymentRun.Bank_Payment_Line_Items__r) {
				bankPaymentIds.add(lineItem.Zumzum__Bank_Payment__c);
			}
		}
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
				WHERE Id IN :bankPaymentIds
		];

		return payments;
	}
}