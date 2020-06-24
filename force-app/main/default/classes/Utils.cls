public with sharing class Utils {
    private static final Integer SUFFIX_NUMBER_DIGITS = 10;

    public static String generateSuffix() {
        return '.' + URL.getSalesforceBaseUrl().getHost().substringBefore('.') + '.' + generateRandomSuffixNumber();
    }

    public static String generateRandomSuffixNumber() {
        String numberStr = '';
        for(Integer i = 0; i < SUFFIX_NUMBER_DIGITS; i++) {
            numberStr += Integer.valueof((Math.random() * 9));
        }

        return numberStr;
    }
}
