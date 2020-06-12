public with sharing class UserEncryptionDecryptionProvider {
    public static String encrypt(String dataToEncrypt, String userId) {
        String strEncrypted = ued.UserCryptoHelper.doEncrypt(dataToEncrypt, userId);
        return strEncrypted;
    }
    public static String decrypt(String dataToDecrypt) {
        dataToDecrypt = EncodingUtil.urlDecode(dataToDecrypt, 'UTF-8').replace(' ', '+');
        String strDecrypted = ued.UserCryptoHelper.doDecrypt(dataToDecrypt);
        return strDecrypted;
    }
}
