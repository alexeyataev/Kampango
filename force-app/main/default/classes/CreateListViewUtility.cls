public with sharing class CreateListViewUtility {
    private static List<String> bodyItems;

    public static void createListViews(Map<String, Object> arguments){

        String whitespaceAndHyphenAndDotRegExp = '[ .-]+';
        String whitespaceAndHyphenAndDotReplacement = '_';

        for (String listViewName : (Set<String>)arguments.get('listViewNameSet')){
            for (String psaAreaName : (Set<String>)arguments.get('psaAreaNameSet')){
                bodyItems = new List<String>();
                HTTPRequest req = new HTTPRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('SOAPAction', 'create');

                setHeadConstantRequestBodyItems();
                bodyItems.add('<fullName>' + (String)arguments.get('objectName') + '.X' + psaAreaName + '_' + listViewName.replaceAll(whitespaceAndHyphenAndDotRegExp, whitespaceAndHyphenAndDotReplacement) + '</fullName>');
                if (String.isNotBlank(((Map<String, String>)arguments.get('filterLogicMap')).get(listViewName))){
                    bodyItems.add('<booleanFilter>' + ((Map<String, String>)arguments.get('filterLogicMap')).get(listViewName) + '</booleanFilter>');
                }
                for (String columnName : (Set<String>)arguments.get('columnNameSet')){
                    bodyItems.add('<columns>' + columnName + '</columns>');
                }
                bodyItems.add('<filterScope>Everything</filterScope>');
                if (!((Map<String, List<Map<String, String>>>)arguments.get('filterCriteriaMap')).get(listViewName).isEmpty()) {
                    setFilterRequestBodyItems(((Map<String, List<Map<String, String>>>)arguments.get('filterCriteriaMap')).get(listViewName), psaAreaName);
                }
                bodyItems.addAll(new List<String>{
                    '<label>' + psaAreaName + ' - ' + listViewName + '</label>',
                    '<sharedTo>',
                    '<group>X' + psaAreaName + '_PSA_Area</group>',
                    '</sharedTo>'
                });
                setTailConstantRequestBodyItems();
                String body = String.join(bodyItems, '');

                req.setBody(body);
                req.setCompressed(false);
                req.setEndpoint(System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/48.0');
                HTTPResponse resp = (new HTTP()).send(req);
                System.debug(resp.getBody());
            }
        }
    }

    private static void setHeadConstantRequestBodyItems(){
        bodyItems.addAll(new List<String>{
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">',
            '<soapenv:Header>',
            '<ns1:SessionHeader soapenv:mustUnderstand="0" xmlns:ns1="http://soap.sforce.com/2006/04/metadata">',
            '<ns1:sessionId>' + UserInfo.getSessionId() + '</ns1:sessionId>',
            '</ns1:SessionHeader>',
            '</soapenv:Header>',
            '<soapenv:Body>',
            '<create xmlns="http://soap.sforce.com/2006/04/metadata">',
            '<metadata xsi:type="ns2:ListView" xmlns:ns2="http://soap.sforce.com/2006/04/metadata">'
        });
    }

    private static void setFilterRequestBodyItems(List<Map<String, String>> listViewCriterionMap, String psaAreaName){
        for (Map<String, String> criterionMap : listViewCriterionMap){
            String fieldValue = criterionMap.get('value') == 'psaAreaName' ? psaAreaName : criterionMap.get('value');
            bodyItems.addAll(new List<String>{
                '<filters>',
                '<field>' + criterionMap.get('field') + '</field>',
                '<operation>' + criterionMap.get('operation') + '</operation>',
                '<value>' + fieldValue + '</value>',
                '</filters>'
            });
        }
    }
    
    private static void setTailConstantRequestBodyItems(){
        bodyItems.addAll(new List<String>{
            '</metadata>',
            '</create>',
            '</soapenv:Body>',
            '</soapenv:Envelope>'
        });
    }
}