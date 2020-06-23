@IsTest
public class EncryptDecryptSalesInvoiceValCodeTest {
    private static final String CREATED_DATE = String.valueOf(Date.today());
    private static final String VALUE_TO_ENCRYPT_1 = 'salesInvoiceName1,' + CREATED_DATE;
    private static final String VALUE_TO_ENCRYPT_2 = 'salesInvoiceName2,' + CREATED_DATE;
    @IsTest
    static void DecryptValidationCodeSuccess_GuestUserTriesToDecrypt_ValidationCodeDecrypted() {
        List<User> uGuest = [SELECT Id FROM User WHERE Profile.Name = 'Parent Community Profile'];
        List<List<String>> dataToEncrypt = new List<List<String>> {new List<String> {VALUE_TO_ENCRYPT_1}, new List<String> {VALUE_TO_ENCRYPT_2}};
        List<DecryptAdhocValidationCodeHandler.AdhocValidationData> salesInvoiceValidationData1;
        List<DecryptAdhocValidationCodeHandler.AdhocValidationData> salesInvoiceValidationData2;
        Test.startTest();
        List<List<String>> encryptedValidationCodeList = EncryptBookingValidationCodeHandler.encrypt(dataToEncrypt);
        System.runAs(uGuest[0]) {
            salesInvoiceValidationData1 = DecryptAdhocValidationCodeHandler.decrypt(encryptedValidationCodeList[0]);
            salesInvoiceValidationData2 = DecryptAdhocValidationCodeHandler.decrypt(encryptedValidationCodeList[1]);
        }
        Test.stopTest();
        System.assertEquals(salesInvoiceValidationData1[0].salesInvoiceName, 'salesInvoiceName1');
        System.assertEquals(salesInvoiceValidationData1[0].salesInvoiceCreatedDate, CREATED_DATE);
        System.assertEquals(salesInvoiceValidationData2[0].salesInvoiceName, 'salesInvoiceName2');
        System.assertEquals(salesInvoiceValidationData2[0].salesInvoiceCreatedDate, CREATED_DATE);
    }
    @IsTest
    static void DecryptValidationCodeFailure_InternalUserTriesToDecrypt_ValidationCodeNotDecrypted() {
        List<List<String>> dataToEncrypt = new List<List<String>> {new List<String> {VALUE_TO_ENCRYPT_1}, new List<String> {VALUE_TO_ENCRYPT_2}};
        List<DecryptAdhocValidationCodeHandler.AdhocValidationData> salesInvoiceValidationData1;
        List<DecryptAdhocValidationCodeHandler.AdhocValidationData> salesInvoiceValidationData2;
        Test.startTest();
        List<List<String>> encryptedValidationCodeList = EncryptBookingValidationCodeHandler.encrypt(dataToEncrypt);
        salesInvoiceValidationData1 = DecryptAdhocValidationCodeHandler.decrypt(encryptedValidationCodeList[0]);
        salesInvoiceValidationData2 = DecryptAdhocValidationCodeHandler.decrypt(encryptedValidationCodeList[1]);
        Test.stopTest();
        System.assertEquals(salesInvoiceValidationData1[0], null);
        System.assertEquals(salesInvoiceValidationData2[0], null);
    }
}