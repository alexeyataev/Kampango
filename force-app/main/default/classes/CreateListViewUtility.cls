public with sharing class CreateListViewUtility {
    public static HttpResponse createListsView(Set<String> psaAreaNameSet, Set<String> listViewNameSet, Map<String, List<Map<String, String>>> filterCriteriaMap, String objectName) {

        String regExp = '[ -]+';
        String replacement = '_';
        HTTPResponse resp;

        for (String listViewName : listViewNameSet) {
            for (String psaAreaName : psaAreaNameSet) {
                HTTP h = new HTTP();
                HTTPRequest req = new HTTPRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('SOAPAction', 'create');

                String requestBody = '<?xml version="1.0" encoding="UTF-8"?>';
                requestBody += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                requestBody += '<soapenv:Header>';
                requestBody += '<ns1:SessionHeader soapenv:mustUnderstand="0" xmlns:ns1="http://soap.sforce.com/2006/04/metadata">';
                requestBody += '<ns1:sessionId>' + UserInfo.getSessionId() + '</ns1:sessionId>';
                requestBody += '</ns1:SessionHeader>';
                requestBody += '</soapenv:Header>';
                requestBody += '<soapenv:Body>';
                requestBody += '<create xmlns="http://soap.sforce.com/2006/04/metadata">';
                requestBody += '<metadata xsi:type="ns2:ListView" xmlns:ns2="http://soap.sforce.com/2006/04/metadata">';
                requestBody += '<fullName>' + objectName + '.X' + psaAreaName + '_' + listViewName.replaceAll(regExp, replacement) + '</fullName>';
                requestBody += '<columns>PSA_Area__c</columns>';
                requestBody += '<columns>NAME</columns>';
                requestBody += '<columns>Sub_Type__c</columns>';
                requestBody += '<columns>Branch__c</columns>';
                requestBody += '<columns>Start_Date__c</columns>';
                requestBody += '<columns>End_Date__c</columns>';
                requestBody += '<columns>Target_Group__c</columns>';
                requestBody += '<columns>Main_Practitioner__c</columns>';
                requestBody += '<columns>Status__c</columns>';
                requestBody += '<columns>Break_Even_Number_Of_Places__c</columns>';
                requestBody += '<columns>Confirmed_Places__c</columns>';
                requestBody += '<columns>Reserved_Places__c</columns>';
                requestBody += '<columns>Enquiries__c</columns>';
                requestBody += '<columns>Remaining_Places__c</columns>';
                requestBody += '<filterScope>Everything</filterScope>';
                for (Map<String, String> criterionMap : filterCriteriaMap.get(listViewName)) {
                    requestBody += '<filters>';
                    requestBody += '<field>' + criterionMap.get('field') + '</field>';
                    requestBody += '<operation>' + criterionMap.get('operation') + '</operation>';
                    requestBody += '<value>' + criterionMap.get('value') + '</value>';
                    requestBody += '</filters>';
                }
                requestBody += '<filters>';
                requestBody += '<field>PSA_Area__c</field>';
                requestBody += '<operation>equals</operation>';
                requestBody += '<value>' + psaAreaName + '</value>';
                requestBody += '</filters>';
                requestBody += '<label>' + psaAreaName + ' - ' + listViewName + '</label>';
                requestBody += '<sharedTo>';
                requestBody += '<group>X' + psaAreaName + '_PSA_Area</group>';
                requestBody += '</sharedTo>';
                requestBody += '</metadata>';
                requestBody += '</create>';
                requestBody += '</soapenv:Body>';
                requestBody += '</soapenv:Envelope>';

                req.setBody(requestBody);
                req.setCompressed(false);
                req.setEndpoint('https://parentforce--dev6.cs85.my.salesforce.com/services/Soap/m/48.0');
                resp = h.send(req);
                System.debug(resp.getBody());
            }
        }
        return resp;
    }
}

/**************************************************************
Set this to org endpoint and add to the remote site settings.
Endpoint: 'YourInstance/services/Soap/m/48.0'
***************************************************************
Bear in mind 100 callouts limit from anonymous execution
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
*/