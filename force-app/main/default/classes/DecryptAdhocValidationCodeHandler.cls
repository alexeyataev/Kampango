public with sharing class DecryptAdhocValidationCodeHandler {
    @InvocableMethod
    public static List<AdhocValidationData> decrypt(List<String> dataToDecrypt) {
        try {
            if(dataToDecrypt == null || dataToDecrypt.size() != 1 || dataToDecrypt[0] == null) {
                throw new ListException('1 value to decrypt must be passed');
            }
            String decryptedString = UserEncryptionDecryptionProvider.decryptUrl(dataToDecrypt[0]);
            AdhocValidationData adhocValidationData = parseSalesInvoiceData(decryptedString);
            return new List<AdhocValidationData> {adhocValidationData};
        } catch(Exception e) {
            return new List<AdhocValidationData> {null};
        }
    }
    private static AdhocValidationData parseSalesInvoiceData(String decryptedString) {
        List<String> decryptedValues = decryptedString.split(',');
        if(decryptedValues.size() > 1) {
            AdhocValidationData adhocValidationData = new AdhocValidationData(decryptedValues[0], decryptedValues[1]);
            return adhocValidationData;
        } else {
            return null;
        }
    }
    public class AdhocValidationData {
        AdhocValidationData(String salesInvoiceName, String salesInvoiceCreatedDate) {
            this.salesInvoiceName = salesInvoiceName;
            this.salesInvoiceCreatedDate = salesInvoiceCreatedDate;
        }
        @InvocableVariable public String salesInvoiceName;
        @InvocableVariable public String salesInvoiceCreatedDate;
    }
}