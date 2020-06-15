public with sharing class DecryptBookingValidationCodeHandler {
    @InvocableMethod
    public static List<BookingValidationData> decrypt(List<String> dataToDecrypt) {
        try {
            if(dataToDecrypt == null || dataToDecrypt.size() != 1 || dataToDecrypt[0] == null) {
                throw new ListException('1 value to decrypt must be passed');
            }
            String decryptedString = UserEncryptionDecryptionProvider.decryptUrl(dataToDecrypt[0]);
            BookingValidationData bookingValidationData = parseBookingData(decryptedString);
            return new List<BookingValidationData> {bookingValidationData};
        } catch(Exception e) {
            return new List<BookingValidationData> {parseBookingData(e.getMessage())};
        }
    }
    private static BookingValidationData parseBookingData(String decryptedString) {
        List<String> decryptedValues = decryptedString.split(',');
        if(decryptedValues.size() > 1) {
            BookingValidationData bookingValidationData = new BookingValidationData(decryptedValues[0], decryptedValues[1]);
            return bookingValidationData;
        } else {
            return null;
        }
    }
    public class BookingValidationData {
        BookingValidationData(String bookingName, String bookingValidationCode) {
            this.bookingName = bookingName;
            this.bookingValidationCode = bookingValidationCode;
        }
        @InvocableVariable public String bookingName;
        @InvocableVariable public String bookingValidationCode;
    }
}
