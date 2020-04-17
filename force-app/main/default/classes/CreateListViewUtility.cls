public with sharing class CreateListViewUtility {
    public static void createListsView(Map<String, Object> arguments) {

        String regExp = '[ -]+';
        String replacement = '_';

        for (String listViewName : (Set<String>)arguments.get('listViewNameSet')) {
            for (String psaAreaName : (Set<String>)arguments.get('psaAreaNameSet')) {
                HTTPRequest req = new HTTPRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('SOAPAction', 'create');

                List<String> bodyItems = new List<String>{
                    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">',
                    '<soapenv:Header>',
                    '<ns1:SessionHeader soapenv:mustUnderstand="0" xmlns:ns1="http://soap.sforce.com/2006/04/metadata">',
                    '<ns1:sessionId>' + UserInfo.getSessionId() + '</ns1:sessionId>',
                    '</ns1:SessionHeader>',
                    '</soapenv:Header>',
                    '<soapenv:Body>',
                    '<create xmlns="http://soap.sforce.com/2006/04/metadata">',
                    '<metadata xsi:type="ns2:ListView" xmlns:ns2="http://soap.sforce.com/2006/04/metadata">',
                    '<fullName>' + (String)arguments.get('objectName') + '.X' + psaAreaName + '_' + listViewName.replaceAll(regExp, replacement) + '</fullName>',
                    '<columns>PSA_Area__c</columns>',
                    '<columns>NAME</columns>',
                    '<columns>Sub_Type__c</columns>',
                    '<columns>Branch__c</columns>',
                    '<columns>Start_Date__c</columns>',
                    '<columns>End_Date__c</columns>',
                    '<columns>Target_Group__c</columns>',
                    '<columns>Main_Practitioner__c</columns>',
                    '<columns>Status__c</columns>',
                    '<columns>Break_Even_Number_Of_Places__c</columns>',
                    '<columns>Confirmed_Places__c</columns>',
                    '<columns>Reserved_Places__c</columns>',
                    '<columns>Enquiries__c</columns>',
                    '<columns>Remaining_Places__c</columns>',
                    '<filterScope>Everything</filterScope>'
                };
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
                    '<field>PSA_Area__c</field>',
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
                req.setEndpoint('https://parentforce--dev6.cs85.my.salesforce.com/services/Soap/m/48.0');
                HTTPResponse resp = (new HTTP()).send(req);
                System.debug(resp.getBody());
            }
        }
    }
}

/**************************************************************
Set this to org endpoint and add to the remote site settings:
Endpoint: 'YourInstance/services/Soap/m/48.0'
***************************************************************
Bear in mind 100 callouts limit from per transaction
Callouts number = PSA_Areas_Number x Lists_View_Number
***************************************************************
Examples of data structures for feeding:

Map<String, List<Map<String, String>>> filterCriteriaMap = new Map<String, List<Map<String, String>>>{
    'All' => new List<Map<String, String>>{
    },
    'Completed' => new List<Map<String, String>>{
        new Map<String, String>{
            'field' => 'Status__c',
            'operation' => 'equals',
            'value' => 'Final'
        },
        new Map<String, String>{
            'field' => 'End_Date__c',
            'operation' => 'lessThan',
            'value' => 'Today'
        }
    },
    'Complete - Reunion Not Taken Place' => new List<Map<String, String>>{
        new Map<String, String>{
            'field' => 'Status__c',
            'operation' => 'equals',
            'value' => 'Final'
        },
        new Map<String, String>{
            'field' => 'End_Date__c',
            'operation' => 'lessThan',
            'value' => 'TODAY'
        },
        new Map<String, String>{
            'field' => 'Final_Session_Date__c',
            'operation' => 'greaterOrEqual',
            'value' => 'TODAY'
        }
    },
    'Currently Running' => new List<Map<String, String>>{
        new Map<String, String>{
            'field' => 'Status__c',
            'operation' => 'equals',
            'value' => 'Final'
        },
        new Map<String, String>{
            'field' => 'Start_Date__c',
            'operation' => 'lessOrEqual',
            'value' => 'TODAY'
        },
        new Map<String, String>{
            'field' => 'End_Date__c',
            'operation' => 'greaterOrEqual',
            'value' => 'TODAY'
        }
    },
    'Not Started' => new List<Map<String, String>>{
        new Map<String, String>{
            'field' => 'Status__c',
            'operation' => 'equals',
            'value' => 'Draft,Final'
        },
        new Map<String, String>{
            'field' => 'Start_Date__c',
            'operation' => 'greaterOrEqual',
            'value' => 'TODAY'
        }
    }
};

Set<String> psaAreaNameSet = new Set<String>{
    '1C','1W',
	'2A','2B','2C',
	'3A','3B','3D','3E','3F',
	'4A','4B','4C','4D','4E','4F','4G','4H','4I','4J','4K','4L','4M','4N','4P','4Q','4R','4S',
	'5A','5B','5C','5D','5E','5F','5G','5H','5I','5J','5K','5L','5M','5N','5O','5R','5S','5T','5U','5VL',
	'6A','6B','6C','6D','6E',
	'7A','7B','7C'
};

Set<String> listViewNameSet = new Set<String>{
    'All',
    'Completed',
    'Complete - Reunion Not Taken Place',
    'Currently Running',
    'Not Started'
};               
    
String objectName = 'Course__c';

Map<String, Object> arguments = new Map<String, Object>{
    'psaAreaNameSet' => psaAreaNameSet,
    'listViewNameSet' => listViewNameSet,
    'filterCriteriaMap' => filterCriteriaMap,
    'objectName' => objectName
};
*/