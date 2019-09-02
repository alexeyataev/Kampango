public with sharing class GeneratePaymentFileUtil {

	public static final String FILE_PREFIX = 'PSAAccount';
	public static final String FILE_EXTENSION = '.txt';
	public static final String PAYMENT_REFERENCE_PREFIX = 'NCT';
	public static final String PSA_REFERENCE_PREFIX = 'PSA';

	private class PaymentWrapper {

		public String column1 { get; set; }
		public String column2 { get; set; }
		public String column3 { get; set; }
		public String column4 { get; set; }
		public String column5 { get; set; }

		public PaymentWrapper(Zumzum__Bank_Payment__c payment){
			this.column1 = payment.Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c;
			this.column2 = payment.Zumzum__Supplier__r.Zumzum__Bank_Account_No__c;
			this.column3 = this.formatPaymentAmount(payment.Zumzum__Amount__c);
			this.column4 = this.formatBankAccountName(payment.Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c);
			this.column5 = this.generatePaymentReference(payment);
		}

		private String formatPaymentAmount(Decimal amount){
			String amountStr = String.valueOf(amount);
			return amountStr.leftPad(11, '0');
		}

		private String formatBankAccountName(String bankAccountName){
			String formatedAccountName = String.isBlank(bankAccountName) ? '' : bankAccountName;
			return formatedAccountName.leftPad(18, '');
		}

		private String generatePaymentReference(Zumzum__Bank_Payment__c payment){
			String psaArea = payment.Zumzum__Supplier__r.PSA_Area__c;
			String paymentNumber = payment.Name.split('-')[1];
			String reference = PAYMENT_REFERENCE_PREFIX + ' ' + PSA_REFERENCE_PREFIX + ' ' + psaArea + '/' + paymentNumber;
			return reference.rightPad(18, ' ');
		}
	}

	public static String generateTxtString(String batchBankPaymentId){
		List<PaymentWrapper> payments = getPayments(batchBankPaymentId);

		String[] rows = new String[payments.size()];

		for(PaymentWrapper payment: payments){
			String[] columns = new String[5];
			columns.add(payment.column1);
			columns.add(payment.column2);
			columns.add(payment.column3);
			columns.add(payment.column4);
			columns.add(payment.column5);
			String lineStr = String.join(columns, ' ').trim();
			rows.add(lineStr);
		}
		String result = String.join(rows,'\n').trim();
		return result;
	}

	public static String generateTXTFileName(){
		Date cd = Date.today();
		String day = String.valueOf(cd.day()).leftPad(2, '0');
		String month = String.valueOf(cd.month()).leftPad(2, '0');
		String fileName = FILE_PREFIX + day + month + cd.year() + FILE_EXTENSION;
		return fileName;
	}

	private static List<PaymentWrapper> getPayments(String batchBankPaymentId){

		List<Zumzum__Bank_Payment__c> payments =  [
				SELECT Id,
						Zumzum__Supplier__r.Zumzum__Bank_Sort_Code__c,
						Zumzum__Supplier__r.Zumzum__Bank_Account_No__c,
						Zumzum__Amount__c,
						Zumzum__Supplier__r.Zumzum__Bank_Account_Name__c,
						Name,
						Zumzum__Supplier__r.Branch__r.Name,
						Zumzum__Supplier__r.PSA_Area__c
				FROM Zumzum__Bank_Payment__c
				WHERE Zumzum__Batch_Bank_Payment__c = :batchBankPaymentId];

		List<PaymentWrapper> paymentWrappers = new List<PaymentWrapper>();

		for(Zumzum__Bank_Payment__c payment: payments){
			paymentWrappers.add(new PaymentWrapper(payment));
		}

		return paymentWrappers;
	}

}