public with sharing class UserEncryptionDecryptionProvider {
    public static String encrypt(String dataToEncrypt, String userId) {
        try {
            String strEncrypted = ued.UserCryptoHelper.doEncrypt(dataToEncrypt, userId);
            return strEncrypted;
        } catch(Exception e) {
            return null;
        }
    }
    public static String decrypt(String dataToDecrypt) {
        try {
            List<User> userList = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
            system.debug(dataToDecrypt);
            dataToDecrypt = EncodingUtil.urlDecode(dataToDecrypt, 'UTF-8').replace(' ', '+');
            String strDecrypted = ued.UserCryptoHelper.doDecrypt(dataToDecrypt);
            return strDecrypted;
        } catch(Exception e) {
            return null;
        }
    }
}
