public with sharing class CreateListViewUtility {
    public static void createListViews(Map<String, Object> arguments) {

        String regExp = '[ -]+';
        String replacement = '_';

        for (String listViewName : (Set<String>)arguments.get('listViewNameSet')) {
            for (String psaAreaName : (Set<String>)arguments.get('psaAreaNameSet')) {
                HTTPRequest req = new HTTPRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('SOAPAction', 'create');

                List<String> bodyItems = new List<String>{
                    '<?xml version="1.0" encoding="UTF-8"?>',
                    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">',
                    '<soapenv:Header>',
                    '<ns1:SessionHeader soapenv:mustUnderstand="0" xmlns:ns1="http://soap.sforce.com/2006/04/metadata">',
                    '<ns1:sessionId>' + UserInfo.getSessionId() + '</ns1:sessionId>',
                    '</ns1:SessionHeader>',
                    '</soapenv:Header>',
                    '<soapenv:Body>',
                    '<create xmlns="http://soap.sforce.com/2006/04/metadata">',
                    '<metadata xsi:type="ns2:ListView" xmlns:ns2="http://soap.sforce.com/2006/04/metadata">',
                    '<fullName>' + (String)arguments.get('objectName') + '.X' + psaAreaName + '_' + listViewName.replaceAll(regExp, replacement) + '</fullName>'
                };
                for (String columnName : (Set<String>)arguments.get('columnNameSet')) {
                    bodyItems.add('<columns>' + columnName + '</columns>');
                }
                bodyItems.addAll(new List<String>{
                    '<filterScope>Everything</filterScope>'
                });
                for (Map<String, String> criterionMap : ((Map<String, List<Map<String, String>>>)arguments.get('filterCriteriaMap')).get(listViewName)) {
                    bodyItems.addAll(new List<String>{
                        '<filters>',
                        '<field>' + criterionMap.get('field') + '</field>',
                        '<operation>' + criterionMap.get('operation') + '</operation>',
                        '<value>' + criterionMap.get('value') + '</value>',
                        '</filters>'
                    });
                }
                bodyItems.addAll(new List<String>{
                    '<filters>',
                    '<field>' + (String)arguments.get('psaAreaFieldName') + '</field>',
                    '<operation>equals</operation>',
                    '<value>' + psaAreaName + '</value>',
                    '</filters>',
                    '<label>' + psaAreaName + ' - ' + listViewName + '</label>',
                    '<sharedTo>',
                    '<group>X' + psaAreaName + '_PSA_Area</group>',
                    '</sharedTo>',
                    '</metadata>',
                    '</create>',
                    '</soapenv:Body>',
                    '</soapenv:Envelope>'
                });

                String body = String.join(bodyItems, '');

                req.setBody(body);
                req.setCompressed(false);
                req.setEndpoint(System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/48.0');
                HTTPResponse resp = (new HTTP()).send(req);
                System.debug(resp.getBody());
            }
        }
    }
}