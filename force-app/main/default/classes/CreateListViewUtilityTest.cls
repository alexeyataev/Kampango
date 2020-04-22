@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #85 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class CreateListViewUtilityTest {
    private static final Map<String, List<Map<String, String>>> FILTER_CRITERIA_MAP = new Map<String, List<Map<String, String>>>{
        'All' => new List<Map<String, String>>{
            new Map<String, String>{
                'field' => 'PSA_Area__c',
                'operation' => 'equals',
                'value' => 'psaAreaName'
            }
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
            },
            new Map<String, String>{
                'field' => 'PSA_Area__c',
                'operation' => 'equals',
                'value' => 'psaAreaName'
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
            },
            new Map<String, String>{
                'field' => 'PSA_Area__c',
                'operation' => 'equals',
                'value' => 'psaAreaName'
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
            },
            new Map<String, String>{
                'field' => 'PSA_Area__c',
                'operation' => 'equals',
                'value' => 'psaAreaName'
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
            },
            new Map<String, String>{
                'field' => 'PSA_Area__c',
                'operation' => 'equals',
                'value' => 'psaAreaName'
            }
        }
    };

    private static final Map<String, String> FILTER_LOGIC_MAP = new Map<String, String>{
        'Completed' => '1 AND (2 OR 3)'
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

    private static final Set<String> COLUMN_NAME_SET = new Set<String>{
        'PSA_Area__c',
        'Completed',
        'Branch__c',
        'Start_Date__c',
        'End_Date__c',
        'Target_Group__c',
        'Main_Practitioner__c',
        'Status__c',
        'Break_Even_Number_Of_Places__c',
        'Confirmed_Places__c',
        'Reserved_Places__c',
        'Enquiries__c',
        'Remaining_Places__c'
    };
    
    private static final String OBJECT_NAME = 'Course__c';

    private static final Map<String, Object> ARGUMENTS = new Map<String, Object>{
        'psaAreaNameSet' => PSA_AREA_NAME_SET,
        'listViewNameSet' => LIST_VIEW_NAME_SET,
        'filterCriteriaMap' => FILTER_CRITERIA_MAP,
        'filterLogicMap' => FILTER_LOGIC_MAP,
        'columnNameSet' => COLUMN_NAME_SET,
        'objectName' => OBJECT_NAME
    };

    @IsTest
    private static void CreateListsViewForPSAAreas_ListsViewCreated(){
        Test.setMock(HttpCalloutMock.class, new CreateListViewUtilityMock());
        Boolean hasError = false;

        Test.startTest();
        try{
            CreateListViewUtility.createListViews(ARGUMENTS);
        }catch(Exception e){
            hasError = true;
        }
        Test.stopTest();

        System.assert(!hasError);
    }
}