public class ProjectAndFieldWrapper {
    public String projecName{get;set;}
    public list<Jira_ProjectFieldsMapping__c> OpJiraFieldList{get;set;}
    public list<Jira_ProjectFieldsMapping__c> ReqJiraFieldList{get;set;}
    public map<String,String>FieldDetailAndId{get;set;}
    public list<SelectOption> ReqJfOptions{get;set;}
    public list<SelectOption> OpJfOptions{get;set;}
    
    public ProjectAndFieldWrapper(String projecName,list<Jira_ProjectFieldsMapping__c> ReqJiraFieldList,list<Jira_ProjectFieldsMapping__c> OpJiraFieldList,list<SelectOption> ReqJfOptions,list<SelectOption> OpJfOptions){
        this.projecName=projecName;
        this.ReqJiraFieldList=ReqJiraFieldList;
        this.OpJiraFieldList=OpJiraFieldList;
        this.ReqJfOptions=ReqJfOptions;
        this.OpJfOptions=OpJfOptions;
    }
    public ProjectAndFieldWrapper(){
        OpJiraFieldList=new  list<Jira_ProjectFieldsMapping__c>();
        ReqJiraFieldList=new  list<Jira_ProjectFieldsMapping__c>();
    }
}