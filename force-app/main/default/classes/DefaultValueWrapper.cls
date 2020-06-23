public class DefaultValueWrapper {
    public String SelectObject{get;set;}
    public String JiraFieldApi{get;set;}
   
    public list<DynamicFieldWrapper> JiraFields {get;set;}
    public DefaultValueWrapper(){
        JiraFields  = new List<DynamicFieldWrapper>();
        
    }
    public DefaultValueWrapper(String SelectObject, String JiraFieldApi, String JiraProjectId){
        this.SelectObject = SelectObject;
        this.JiraFieldApi = JiraFieldApi; 
        JiraFields  = new List<DynamicFieldWrapper>();
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            for(Jira_ProjectFieldsMapping__c jiraField:[SELECT Id, Name, ReadOnly__c , Jira_Project__r.subtask__c,Jira_Project__c, Jira_Project__r.name,IsArray__c,  DataType__c,  Default_Value_long__c,  
                                                        Jira_Field_Name__c,ViewMode__c,Order__c, Section__c,Enable_Record_Mapping__c, ReqInIssueTypeData__c,IssueTypedata__c, JIRA_Field_Api_Name__c,  Salesforce_Object__c , ProjectissueTypeData__c 
                                                        FROM  Jira_ProjectFieldsMapping__c 
                                                        where Jira_Project__c=:JiraProjectId and  JIRA_Field_Api_Name__c=:JiraFieldApi and  Salesforce_Object__c =: SelectObject]){
                                                         
                                                            JiraFields.add(new DynamicFieldWrapper(jiraField,''));
                                                        }
        }
    }
    
    
}