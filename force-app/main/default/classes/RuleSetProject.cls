/**
* @Author Grazitti
* Helper class for fetching rule set and find the appropriate project.
*/
public class RuleSetProject {
    public static String getProjectName(Id ObjId){
       String projectName;
        Map<String,Schema.SObjectField> vRulesObjectFields = Rule_Set__c.sObjectType.getDescribe().fields.getMap();
        Map<String,Schema.SObjectField> vRulesChildObjectFields = Child_Rule_Set__c.sObjectType.getDescribe().fields.getMap();
        
        String parentQuery = 'Select ';
        for(String field : vRulesObjectFields.keySet()){
            if(vRulesObjectFields.get(field).getDescribe().isAccessible()){
                parentQuery +=   field + ', ';
            }
        }
        
        String childQuery = '(Select ';
        for(String field : vRulesChildObjectFields.keySet()){
            if(vRulesChildObjectFields.get(field).getDescribe().isAccessible()){
                childQuery +=   field + ', ';
            }
        }
        childQuery = childQuery.removeEnd(', ');
        String finalChildQuery = childQuery + ' from Child_Rule_Sets__r)';
        String objectName = String.valueOf(ObjId.getSObjectType().getDescribe().getName());
        String finalParentQuery = parentQuery + finalChildQuery + ' from Rule_Set__c where isActive__c = true and RuleSetObject__c =: objectName ORDER by SNO__c LIMIT 90';
        Set<string> uniqueQueryField  = new Set<String>();
        Map<String,String> mapSNOToValue = new Map<String,String>();        
        if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.isAccessible()){                 
            for (Rule_Set__c tempRuleset : Database.Query(finalParentQuery)){    
                //Constructing the dynamic query on the basis of Rulesets and related sObject record
                String finalQuery = '';
                String startQuery = 'Select Id ';
                String fieldsToFetch = ''; 
                // Filtering conditions define the filter logic for "OR" & "AND" defined on Admin Screen
                String filteringCondition = tempRuleSet.FilterLogic__c;
                Boolean isForLoopExecuted = false;
                String filteredString = '';
                
                //Looping through all the rules associated to a particular rule-set to check whether the related record (of Account or Contact or Lead etc fulfills the rule criterion)
                for (Child_Rule_Set__c tempRules : tempRuleset.Child_Rule_Sets__r){
                    if(!uniqueQueryField.contains(String.valueOf(tempRuleset.ruleSetObject__c)+'_'+String.valueOf(tempRules.Field_Name__c))){
                        fieldsToFetch   +=    ', ' + tempRules.Field_Name__c;
                        uniqueQueryField.add(String.valueOf(tempRuleset.ruleSetObject__c)+'_'+String.valueOf(tempRules.Field_Name__c));
                    }
                    String dynamicFilter = tempRules.Dynamic_Filter_Logic__c;
                    if(tempRules.Dynamic_Filter_Logic__c.indexOf('\\') > -1) dynamicFilter = tempRules.Dynamic_Filter_Logic__c.remove('\\');
                    mapSNOToValue.put(tempRules.SNO__c,dynamicFilter);   
                    
                    isForLoopExecuted = true;
                }
                
                if(isForLoopExecuted == true && !mapSNOToValue.isEmpty() && mapSNOToValue.size()>0 && filteringCondition != null){              
                    
                    //Handling the filters OR & AND
                    if(filteringCondition.indexOf('AND') > -1) filteringCondition = filteringCondition.replaceAll('AND','A');                            
                    if(filteringCondition.indexOf('OR') > 0-1) filteringCondition = filteringCondition.replaceAll('OR','O');                        
                    //Handling the filtering conditions with the assumption that maximum five filters will be defined per ruleset
                    for(Integer i=0; i<filteringCondition.length(); i++){
                        String str = String.valueOf(filteringCondition.charAt(i));                                
                        if(filteringCondition.charAt(i) == 49){ if(mapSNOToValue.containsKey('1')){ filteredString += ' '+mapSNOToValue.get('1')+' '; }  }
                        if(filteringCondition.charAt(i) == 50){ if(mapSNOToValue.containsKey('2')){ filteredString += ' '+mapSNOToValue.get('2')+' '; }  }
                        if(filteringCondition.charAt(i) == 51){ if(mapSNOToValue.containsKey('3')){ filteredString += ' '+mapSNOToValue.get('3')+' '; }  }
                        if(filteringCondition.charAt(i) == 52){ if(mapSNOToValue.containsKey('4')){ filteredString += ' '+mapSNOToValue.get('4')+' '; }  }
                        if(filteringCondition.charAt(i) == 53){ if(mapSNOToValue.containsKey('5')){ filteredString += ' '+mapSNOToValue.get('5')+' '; }  }
                        if(filteringCondition.charAt(i) == 40) filteredString += ' ( ';
                        if(filteringCondition.charAt(i) == 41) filteredString += ' ) ';
                        if(filteringCondition.charAt(i) == 65) filteredString += ' AND ';
                        if(filteringCondition.charAt(i) == 79) filteredString += ' OR ';                               
                    }
                    
                    if(filteredString != '' && filteredString.length()>0){                             
                        //Contrusting the final query that needs to fired into the Database
                        finalQuery = startQuery + fieldsToFetch  + ' FROM '+objectName+' where ( ' + filteredString + ' ) and Id =: ObjId';
                    }
                }   
                isForLoopExecuted = false; 
                //Fetching/checking the account/contact/lead/Opp if it matches all the filtering conditions of any of the related ruleset.
                //If matching record is found, the user is directed to directive URL bound with related rulset
                //If matching record is not found, the user is directed to default home page
                List<sObject> fetchedResults = new List<sObject>();
                if(finalQuery  != '' && finalQuery.length() > 0){
                    fetchedResults = Database.query(finalQuery);
                    if(fetchedResults.size() > 0 ){
                        projectName = tempRuleset.Project__c;                                        
                        break;
                    }              
                }                               
            }  
        }                 
        return projectName;
    }
}