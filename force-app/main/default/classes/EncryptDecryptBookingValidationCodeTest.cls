@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest
public class EncryptDecryptBookingValidationCodeTest {
    private static final String VALUE_TO_ENCRYPT_1 = 'bookingName1,28638261';
    private static final String VALUE_TO_ENCRYPT_2 = 'bookingName2,28638262';
    @IsTest
    static void DecryptValidationCodeSuccess_GuestUserTriesToDecrypt_ValidationCodeDecrypted() {
        List<User> uGuest = [SELECT Id FROM User WHERE Profile.Name = 'Parent Community Profile'];
        List<List<String>> dataToEncrypt = new List<List<String>> {new List<String> {VALUE_TO_ENCRYPT_1}, new List<String> {VALUE_TO_ENCRYPT_2}};
        List<DecryptBookingValidationCodeHandler.BookingValidationData> bookingValidationData1;
        List<DecryptBookingValidationCodeHandler.BookingValidationData> bookingValidationData2;
        Test.startTest();
        List<List<String>> encryptedValidationCodeList = EncryptBookingValidationCodeHandler.encrypt(dataToEncrypt);
        System.runAs(uGuest[0]) {
            bookingValidationData1 = DecryptBookingValidationCodeHandler.decrypt(encryptedValidationCodeList[0]);
            bookingValidationData2 = DecryptBookingValidationCodeHandler.decrypt(encryptedValidationCodeList[1]);
        }
        Test.stopTest();
        System.assertEquals(bookingValidationData1[0].bookingName, 'bookingName1');
        System.assertEquals(bookingValidationData1[0].bookingValidationCode, '28638261');
        System.assertEquals(bookingValidationData2[0].bookingName, 'bookingName2');
        System.assertEquals(bookingValidationData2[0].bookingValidationCode, '28638262');
    }
    @IsTest
    static void DecryptValidationCodeFailure_InternalUserTriesToDecrypt_ValidationCodeNotDecrypted() {
        List<List<String>> dataToEncrypt = new List<List<String>> {new List<String> {VALUE_TO_ENCRYPT_1}, new List<String> {VALUE_TO_ENCRYPT_2}};
        List<DecryptBookingValidationCodeHandler.BookingValidationData> bookingValidationData1;
        List<DecryptBookingValidationCodeHandler.BookingValidationData> bookingValidationData2;
        Test.startTest();
        List<List<String>> encryptedValidationCodeList = EncryptBookingValidationCodeHandler.encrypt(dataToEncrypt);
        bookingValidationData1 = DecryptBookingValidationCodeHandler.decrypt(encryptedValidationCodeList[0]);
        bookingValidationData2 = DecryptBookingValidationCodeHandler.decrypt(encryptedValidationCodeList[1]);
        Test.stopTest();
        System.assertEquals(bookingValidationData1[0], null);
        System.assertEquals(bookingValidationData2[0], null);
    }
}
