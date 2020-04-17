//@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #XX - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class CreateListViewUtilityTest {
    private static final Map<String, List<Map<String, String>>> FILTER_CRITERIA_MAP = new Map<String, List<Map<String, String>>>{
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

    private static final Set<String> PSA_AREA_NAME_SET = new Set<String>{
        '1C','1W',
        '2A','2B','2C',
        '3A','3B','3D',
        '4A','4B','4C',
        '5A','5B','5C',
        '6A','6B','6C',
        '7A','7B','7C'
    };

    private static final Set<String> LIST_VIEW_NAME_SET = new Set<String>{
        'All',
        'Completed',
        'Complete - Reunion Not Taken Place',
        'Currently Running',
        'Not Started'
    };
    
    private static final String OBJECT_NAME = 'Course__c';

    @IsTest
    private static void CreateListsViewForPSAAreas_ListsViewCreated(){
        Test.setMock(HttpCalloutMock.class, new CreateListViewUtilityMock());
        Boolean hasError = false;

        Test.startTest();
        try{
            CreateListViewUtility.createListsView(PSA_AREA_NAME_SET, LIST_VIEW_NAME_SET, FILTER_CRITERIA_MAP, OBJECT_NAME);
        }catch(Exception e){
            hasError = true;
        }
        Test.stopTest();

        System.assert(!hasError);
    }
}
