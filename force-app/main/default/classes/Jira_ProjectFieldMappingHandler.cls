public with Sharing class Jira_ProjectFieldMappingHandler implements ITrigger {
    public set<string> sfobjects = new set<string>();
    public Map<String,set<String>> ProjecttoJiraApiNamesMap= new Map<String,set<String>>();
    public set<id> FieldIdsForReporting = new set<id>();
    public String sfObject = '';
    Set<String> salesforceObject = new Set<String>();
    String caseNumberApi;
    List<Jira_ProjectFieldsMapping__c> defaultList = new List<Jira_ProjectFieldsMapping__c>();
    public void bulkBefore(){}
    public void bulkAfter(){
        
        if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        for(Jira_ProjectFieldsMapping__c jpm : [Select id,name,Salesforce_Object__c from Jira_ProjectFieldsMapping__c where   ID IN : Trigger.newMap.keyset()]){
            
            if(jpm.Salesforce_Object__c!=null && jpm.Salesforce_Object__c!='' && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isAccessible())
                sfobjects.add(jpm.Salesforce_Object__c);
        }
        
        
    }
    public void beforeInsert(SObject so){}
    public void beforeUpdate(SObject oldSo, SObject so){}
    public void beforeDelete(SObject so){}
    public void afterDelete(SObject so){}
    public void afterUpdate(SObject so, Sobject oldSo){ 
        
        Jira_ProjectFieldsMapping__c Jp = (Jira_ProjectFieldsMapping__c)so;
        sfObject = jp.Salesforce_Object__c;
        
        Jira_ProjectFieldsMapping__c OldJp = (Jira_ProjectFieldsMapping__c)oldSo;
        
        if(!Jp.IsStatic__c  ){
            if(ProjecttoJiraApiNamesMap.containsKey(Jp.Jira_Project__c)){
                ProjecttoJiraApiNamesMap.get(Jp.Jira_Project__c).add(Jp.JIRA_Field_Api_Name__c);
            }else{
                ProjecttoJiraApiNamesMap.put(Jp.Jira_Project__c,new  set<String>{Jp.JIRA_Field_Api_Name__c});
            }
        }
        if(jp.IsReportingEnabled__c && !OldJp.IsReportingEnabled__c){
            FieldIdsForReporting.add(jp.id);
        }
    }
    public void afterInsert(SObject so){
        
        Jira_ProjectFieldsMapping__c Jp = (Jira_ProjectFieldsMapping__c)so;
        sfObject = jp.Salesforce_Object__c;
        if(!Jp.IsStatic__c || (caseNumberApi!=null && jp.JIRA_Field_Api_Name__c==caseNumberApi)){
            if(ProjecttoJiraApiNamesMap.containsKey(Jp.Jira_Project__c)){
                ProjecttoJiraApiNamesMap.get(Jp.Jira_Project__c).add(Jp.JIRA_Field_Api_Name__c);
            }else{
                ProjecttoJiraApiNamesMap.put(Jp.Jira_Project__c,new  set<String>{Jp.JIRA_Field_Api_Name__c});
            }
        }
        if(jp.IsReportingEnabled__c){ 
            FieldIdsForReporting.add(jp.id); 
        }
    }
    public void andFinally(){
        
        if(!ProjecttoJiraApiNamesMap.isEmpty()){
            Database.executeBatch(new Jira_ProjectFieldMappingGateway(ProjecttoJiraApiNamesMap,sfObject),1);
        }
        
        if(FieldIdsForReporting.size() > 0){
            
            Database.executeBatch(new UpdateReporintgFields(FieldIdsForReporting, UserInfo.getSessionId()) , 20);
        }
        
        if(!sfobjects.isEmpty()){
            List<string> fieldList = new List<string>();
            Map < String, Schema.SObjectField > fieldMap = new map<string,Schema.SObjectField >();
            //fieldList = new set<string>();
            //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
            fieldMap = Schema.getGlobalDescribe().get('JiraRelationship__c').getDescribe().fields.getMap();
            if(!fieldMap.isempty()){
                for (Schema.SObjectField sfield: fieldMap.Values()) {
                    schema.describefieldresult dfield = sfield.getDescribe();
                    
                    fieldList.add(dfield.getLocalName());
                    
                }
            }
            
            for(string selectedObject : sfobjects){
                if(selectedObject!=null  && selectedObject!=''){
                    if(!fieldList.isEmpty()){
                        
                        if(selectedObject.contains('__c')){
                            selectedObject=selectedObject.removeEnd('__c');
                        }
                        if(selectedObject.contains('__'))
                        {
                            selectedObject=selectedObject.substring(selectedObject.indexof('__')+2,selectedObject.length() ); 
                        }
                        string objectName=selectedObject+'Relation__c';
                        
                        if(!fieldList.contains(objectName) ){
                            
                            Database.executeBatch(new CreateLookUpFieldsandGivePermissions(sfobjects, UserInfo.getSessionId(),fieldList) , 20);
                        }
                        
                    }
                }
            }
        }
    }
    
}