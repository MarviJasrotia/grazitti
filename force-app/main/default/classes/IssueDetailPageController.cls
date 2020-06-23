/**
* @Author Grazitti
* Controller for issuedetailpage.vfp
* responsible for getting the list of cases ,attachments, comments  related to jira.
* 
*/

public with sharing class IssueDetailPageController{
	    public String lang{get;set;}    
    public List<JiraIssue__c> subtasks { get; set;}
     public list<SelectOption> Languages {get;set;}
    public List<JiraRelationship__c> relationList {get; set;}
    
    public Id jiraIssueId;
    
    public String jiraIssueKey;
    
    public List<Map<String,String>> attachmentData {get; set;}
    Map<String,string> objectRelationfield=new Map<String,String>();
    Map<String,Schema.SobjectField> genericfieldMap=new Map<String,Schema.SobjectField>();
    Map<String,String> fieldMap=new Map<String,String>();
    public Set<String> availiableRelations;
    public List<wrapjiraIssue> wrapRelatedSobjectList{get;set;}
    
    public IssueDetailPageController(ApexPages.StandardController controller) {
         lang=userinfo.getLanguage();
        Languages = JiraService.LanguageOptions();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        jiraIssueId = ((JiraIssue__c)controller.getRecord()).Id; 
        if(jiraIssueId!=NULL && JiraIssue__c.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isAccessible()){
            jiraIssueKey = [select IssueKey__c from JiraIssue__c where Id =:jiraIssueId].IssueKey__c;
        }
        Map<String,Schema.SobjectType> SchemaMap=Schema.getGlobalDescribe();
        //NameSpace removed  Grz_Sf__JiraRelationship__c to JiraRelationship__c
        genericFieldMap=schemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
        
        
        
        for(String field:genericFieldMap.keySet()){
            
            fieldMap.put(String.ValueOf(genericFieldMap.get(field)),String.ValueOf(genericFieldMap.get(field).getDescribe().getType()));
        }
        
        String relationshipFields='';
        availiableRelations =new set<String>();
        for(string str :fieldMap.keySet()){
            
            if(fieldMap.get(str).tolowercase()=='reference' && str.contains('Relation__c')){
                
                availiableRelations.add(str);
                String RelName= genericFieldMap.get(str).getDescribe().getRelationshipName();
                
                
                for(Schema.SObjectType objectName : genericFieldMap.get(str).getDescribe().getReferenceTo()){
                    
                    if(!objectRelationfield.containsKey(String.valueOF(objectName)))
                        objectRelationfield.put(String.valueof(objectName),String.valueof(RelName)); 
                    
                    
                    String Fname='';
                    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(String.valueof(objectName)).getDescribe().fields.getMap();
                    
                    
                    if(fieldMap.containskey('name')){
                        Fname=RelName+'.name';
                        
                        if(!relationshipFields .contains(Fname))
                            relationshipFields += Fname +',';
                        
                        
                    }else if(String.valueof(objectName).tolowerCase()=='case'){
                        Fname=RelName+'.CaseNumber';
                        if(!relationshipFields.contains(Fname))
                            relationshipFields += Fname +',';
                        
                        
                    }else if(String.valueof(objectName).tolowerCase()=='idea'){
                        
                        Fname=RelName+'.Title';
                        if(!relationshipFields.contains(Fname))
                            relationshipFields += Fname +',';
                    }
                }
            }
        }
        
        
        
        String Query='SELECT ' + relationshipFields +  'id FROM JiraRelationship__c where  JiraIssue__c =:jiraIssueId';
        
        relationList = new List<JiraRelationship__c>();
        if(JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
            relationList =Database.query(Query);
        }
        wrapRelatedSobjectList =new List<wrapjiraIssue>();
        
        for(JiraRelationship__c jr : relationList){
            
            wrapRelatedSobjectList.add(new wrapjiraIssue(jr,this));
        }
        
        
        
        /*if(String.isNotEmpty(jiraIssueKey)){
JiraService.JiraWrapper jiraWrapperInstance = JiraService.fetchIssueDetails(jiraIssueKey);

if(jiraWrapperInstance!=null){
subtasks = jiraWrapperInstance.subTasksList;
attachmentData = jiraWrapperInstance.attachmentData;
}
}*/
    }  
    
    public class wrapjiraIssue {
        
        public List<wrapjiraInfo> jiraInfoList{get;set;}
        public String objName {get; set;}
        public ID relID {get;set;}
        Set<String> availiableRelations=new Set<String>();
        JiraRelationship__c jiraRelation=new JiraRelationship__c();
        IssueDetailPageController outerinstance;
        Map<String,String> objectRelationfield;
        
        public wrapjiraIssue(JiraRelationship__c jr, IssueDetailPageController outerinstance){
            
            this.outerinstance=outerinstance;
            this.availiableRelations=outerinstance.availiableRelations;
            objectRelationfield=new Map<String,String>(outerinstance.objectRelationfield);
            
            
            
            jiraRelation=jr;
            this.availiableRelations.addall(availiableRelations);
            jiraInfoList = new List<wrapjiraInfo>();
            
            
            Map<String,Object> deserialRelation = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(jiraRelation));
            
            
            
            for(String str : this.availiableRelations){
                
                
                
                if(jiraRelation.get(str)!=NULL && jiraRelation.get(str)!=''){
                    
                    
                    relID =String.valueof(jr.get(str));
                    objName  =relID.getSObjectType().getDescribe().getName();
                    
                    
                    string relName='';
                    
                    if(objName!='case' && objName!='idea'){
                        
                        
                        Map<String,Object> relationName=(Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(deserialRelation.get(String.valueOf(objectRelationfield.get(objName)))));
                        
                        String recordName='';
                        if(relationName.containskey('Name') && relationName.get('Name')!=NULL)
                            recordName=String.valueOF(relationName.get('Name'));
                        String objectLabel=relID.getSObjectType().getDescribe().getLabel();
                        
                        
                        jiraInfoList.add(new wrapjiraInfo(relID,objectLabel,recordName));
                    }else if(objName=='idea'){
                        
                        Map<String,Object> relationName=(Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(deserialRelation.get(String.valueOf(objectRelationfield.get(objName)))));
                        
                        String recordName='';
                        if(relationName.containskey('Title') && relationName.get('Title')!=NULL)
                            recordName=String.valueOF(relationName.get('Title'));
                        
                        jiraInfoList.add(new wrapjiraInfo(relID,objName,recordName)); 
                    }
                    else if(objName=='case'){
                        
                        Map<String,Object> relationName=(Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(deserialRelation.get(String.valueOf(objectRelationfield.get(objName)))));
                        String recordName='';
                        if(relationName.containskey('CaseNumber') && relationName.get('CaseNumber')!=NULL)
                            recordName=String.valueOF(relationName.get('CaseNumber'));
                        
                        jiraInfoList.add(new wrapjiraInfo(relID,objName,recordName)); 
                    }
                }
            }
            
        }
    }
    
    public Class wrapjiraInfo{
        
        public String objectName{get;set;}
        public ID relationid{get;set;}
        public String relationName{get;set;}
        
        public wrapjiraInfo(ID relationid , String objectName,string recordName){
            
            this.objectName=objectName;
            this.relationid=relationid;
            this.relationName=recordName;
        }
    } 
}