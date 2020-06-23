public with sharing class JiraIssueListGenericController{
        public String lang{get;set;}
    /**
* List of  jirawrapper class
*/
    public List<JiraWrapper> jiraIssuesList{get; set;}
    /**
* case id to which all related jiraissue/jirarelation will be fetched 
Modified on 08-07-2019*/
    public String JiraKey{get;set;}
    public String IssueId{get;set;}
    public Id caseId {get; set;}
    public ID genericObjectID{get;set;}
    /**
* String of ';' seperated jira issue keys send as parameter to  CommentsAttachmentsJiraSyncPage 
*/
    //public String jiraKeys {get; set;}
    public string token{get;set;}
    public Jira_login__c setting;
    String modifiedName;
    String objectName='';
    public Integer objectMappingexist{get;set;}
    /**
* gets caseid from standardcontroller
* fills the jiraIssuesList. 
* @param stdandard controller from page (case).
*   
*/
    public JiraIssueListGenericController(){
        lang=userinfo.getLanguage();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        token=String.valueof(Math.random());
        genericObjectID=ApexPages.CurrentPage().getParameters().get('id');
        
        if(genericObjectID!=NULL)
            objectName=genericObjectID.getSObjectType().getDescribe().getName();
        
        modifiedName=objectName;
        if(modifiedName.contains('Grz_Sf__')) {
            modifiedName=modifiedName.remove('Grz_Sf__');
        }
        
        if(modifiedName.containsIgnoreCase('__c')){
            modifiedName= modifiedName.remove('__c');
        }  
        if(modifiedName.contains('__'))modifiedName=modifiedName.substring(modifiedName.indexof('__')+2,modifiedName.length() );
        
        
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        map<String,Schema.SObjectField>  genericFieldMap = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField>  NewgenericFieldMap = new map<String,Schema.SObjectField>();  
        //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
        genericFieldMap= schemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
        
        String nameSpace = '';
        if(Organization.sObjectType.getDescribe().isAccessible() ){
            List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
            
            if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null && Schema.sObjectType.Organization.fields.NameSpacePrefix.isAccessible()){nameSpace = ThisOrg[0].NameSpacePrefix;}
        }
        if(nameSpace==null||nameSpace==''){nameSpace='';}else{nameSpace=nameSpace+'__';}
        for(String key:genericFieldMap.keySet()){
            String Inkey=key.tolowerCase();
            Inkey=Inkey.remove('grz_sf__');
            nameSpace=nameSpace.toLowerCase();
            Inkey=Inkey.remove(nameSpace);
            NewgenericFieldMap.put(Inkey,genericFieldMap.get(key));
        }
        String RelationFieldName;
        if(objectName!=NULL && objectName!=''){
            
            if(NewgenericFieldMap.containskey(modifiedName.tolowercase()+'relation__c')){ 
                
                RelationFieldName=String.valueOf(NewgenericFieldMap.get(modifiedName.tolowercase()+'relation__c'));
                
            }
        }
        
        setting = [select id, Name,License_Key__c, End_Point__c ,LoginSuccess__c
                   from Jira_login__c 
                   where name = 'JIRA'
                   Limit 1
                  ];
        
        if(objectName!=NULL && objectName!='' && Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            List<Jira_ProjectFieldsMapping__c> JP=[SELECT id From Jira_ProjectFieldsMapping__c WHERE Salesforce_Object__c=:objectName LIMIT 1];
            
            objectMappingexist=jp.Size();                                 
        }
        
        //caseId = stndController.getRecord().Id;
        jiraIssuesList = new List<JiraWrapper>();
        String query;
        if(RelationFieldName!='' && RelationFieldName!=NULL )
            query ='SELECT Id,JiraIssue__r.Priority__c,JiraIssue__c,JiraIssue__r.Jira_Link__c,JiraIssue__r.JsonData__c,JiraIssue__r.Status__c, JiraIssue__r.IssueId__c, JiraIssue__r.IssueKey__c,JiraIssue__r.Assignee__c, JiraIssue__r.description__c,JiraIssue__r.Reporter__c, JiraIssue__r.Summary__c FROM JiraRelationship__c where '+RelationFieldName+'= '+'\''+ String.escapeSingleQuotes(genericObjectID) +'\' order by createdDate';
        
        
        List<JiraRelationship__c> jiraRelationList=new  List<JiraRelationship__c> ();
        
        if(query!=NULL && query!='' && JiraRelationship__c.sObjectType.getDescribe().isAccessible())
            jiraRelationList=Database.query(query);
        
        if(jiraRelationList!=NULL && jiraRelationList.size()>0){
            for(JiraRelationship__c jiraIssueInstance : jiraRelationList ){
                
                String resolution='';
                String fixVersions = '';
                if(jiraIssueInstance.JiraIssue__r.JsonData__c != null && jiraIssueInstance.JiraIssue__r.JsonData__c != ''){
                    string Json_val = jiraIssueInstance.JiraIssue__r.JsonData__c;
                    if(Json_val != ''){
                        Map<String,Object> jsonData = (Map<String,Object>)JSON.deserializeUntyped(Json_val);
                        Map<string,Object> FinalMap = (Map<string,Object>)JSON.deserializeUntyped(JSON.Serialize(jsonData.get('fields')));
                        resolution = FinalMap.get('resolution') != null ? FieldJsonHelper.getFieldDataForReporting('resolution',jsonData) : '---';
                        fixVersions = FieldJsonHelper.getFieldDataForReporting('fixVersions' , jsonData);
                    }
                }
                
                fixVersions = fixVersions !='' ? fixVersions : '---';
                JiraWrapper jiraWrapper = new JiraWrapper(false, jiraIssueInstance,resolution,fixVersions);
                jiraIssuesList.add(jiraWrapper);
            }
        }
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
            GenerateJiraLogs.CreateLogRealTime('JiraIssueListGenericController',null, null, null,null,null, null , null, null, 'Delete JiraRelationship', Error);
            
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