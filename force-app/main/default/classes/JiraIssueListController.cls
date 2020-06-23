/**
* Controller for JIRAIssueList visualforce page
* @Grazitti
* version 1.0
* 
*/
public with sharing class JiraIssueListController{
    
    /**
* List of  jirawrapper class
*/
    public List<JiraWrapper> jiraIssuesList{get; set;}
    /**
* case id to which all related jiraissue/jirarelation will be fetched 
*/
    public Id caseId {get; set;}
    /**
* String of ';' seperated jira issue keys send as parameter to  CommentsAttachmentsJiraSyncPage 
*/
    public String jiraKeys {get; set;}
    
    public Jira_login__c setting;
    
    ID GenricobjectID;
    
    /**
* gets caseid from standardcontroller
* fills the jiraIssuesList. 
* @param stdandard controller from page (case).
*   
*/
    public JiraIssueListController(ApexPages.StandardController stndController){
        
        
    }
    /**
* unlink the jira with case.
* delete related jira relationship object
* remove jira values from related case with help of clearJiraFields() . 
*/
    public PageReference unlinkIssues() {
        
        List<JiraRelationship__c> jiraIssueCaseLinks = new List<JiraRelationship__c>();
        Set<Id> removeJiraIssueSet = new Set<Id>();
        try{
            if((JiraRelationship__c.sObjectType.getDescribe().isDeletable())){ 
                for(Integer index=jiraIssuesList.size()-1;index>=0;index--){
                    JiraWrapper jiraIssue = jiraIssuesList.get(index);
                    if(jiraIssue.selected){
                        jiraIssueCaseLinks.add(new JiraRelationship__c(Id=jiraIssue.jiraIssueRel.Id));
                        removeJiraIssueSet.add(jiraIssue.jiraIssueRel.Id);
                        jiraIssuesList.remove(index);
                    }
                }
                if(JiraRelationship__c.sObjectType.getDescribe().isDeletable() && jiraIssueCaseLinks.Size() > 0 ){
                    delete jiraIssueCaseLinks;
                }
                
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraIssueListController',null, null, null,null,null, null , null, null, 'Delete JiraRelationship', Error);
            
        }
        return null;
    }
    /**
* Wrapper class to hold jira relationship and boolean variable.  
*/    
    public class JiraWrapper{
        public Boolean selected{get; set;}
        public JiraRelationship__c jiraIssueRel{get; set;}
        public string resolution {get;set;}
        public string fixVersion {get;set;}
        public JiraWrapper(Boolean selected, JiraRelationship__c jiraIssue, String resolution, String fixVersion){
            this.jiraIssueRel = jiraIssue;
            this.selected = selected;
            this.resolution = resolution;
            this.fixVersion = fixVersion;
        }
    }
    
}