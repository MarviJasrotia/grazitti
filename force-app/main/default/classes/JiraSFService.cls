public class JiraSFService{
    
    public static Map<id,Jira_ProjectFieldsMapping__c> fetchJiraCustomFields(){
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            Map<id,Jira_ProjectFieldsMapping__c> fieldList = new Map<id,Jira_ProjectFieldsMapping__c>([SELECT Id,Salesforce_Object__c,IsReportingEnabled__c, IsStatic__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,  ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Projectkey__c, Jira_Project__r.DefaultIssueType__c, Jira_Project__r.IssueType__c  ,Jira_Field_Name__c , section__c, section__r.column__c, section__r.name FROM  Jira_ProjectFieldsMapping__c order by section__r.order__c,order__c Asc nulls last  limit 1000]);
            
            return fieldList;
        }
        return null;
    }  
    
}