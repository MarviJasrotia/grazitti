global with sharing class ViewJiraIssueController{
    public String lang{get;set;}
    public List<JiraErrorLogs__c> JiraLogsToInsert;
    Public List<Id> Ids=new List<Id>();
    final String JIRA_DATE_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    public integer count{get;set;}
    public string projectName {get; set;}
    public String parents;
    public String SubtaskParentID{get;set;}
    public booleAN IssueType {get; set;}
    public Id jiraIssueId {get; set;}
    
    public set<String> relatedObjectsToJiraIssue;
    
  //  public List<SelectOption> projects {get; set;}
    
    
    public List<JiraIssue__c> parentIssueId ;
    public JiraIssue__c jiraIssue {get; set;}
      
    public map<String,list<DynamicFieldWrapper>> sectionToDynamicFieldWrapperListMap{get; set;}
    public Map<String,Map<String,List<DynamicFieldWrapper>>> sectionToDynamicFieldWrapperListMap2{get;set;}
    public Map<String,List<String>> sectionorder{get;set;}
    public Set<string> objectsLabelList{get;set;}
    
    public Map<String, Jira_ProjectFieldsMapping__c> dynamicFieldsDataMap;
    public List<Jira_ProjectFieldsMapping__c > dynamicFieldsData;
    
    public list<DynamicFieldWrapper> DynamicFieldWrapperList;
    public Map<String, String> jiraProjectskeymap{get;set;} 
    public String errorMessage{get;set;}
    public string mode{get;set;}
    public string modetype{get;set;}
    public Jira_login__c setting{get;set;}
    public boolean EditJiraSetting{get;set;}
    public Boolean ProjectAvailable{get;set;}
    public Boolean IssueIsEditable{get;set;}
    public String RelatedList1{get;set;}
    public Set<String> creatableProjects;
    public Boolean projectIsEditable{get;set;}
    public Boolean HasPermission {get;set;}
    public Boolean HasCommentPermission {get;set;}
    public Map<String, Jira_Project__c> ProjectkeyToObjectmap;
    public Map<String,String> fieldsToKey {get;set;}
    public Integer SizeOfMap { get;set;}
    public Integer SizeOfMapLI { get;set;}
    public String epicKey { get;set;}
    public String issueLinkKey { get;set;}
    public Map<String,List<FieldJsonHelper.LinkedIssues>> IssuelinksMap {get;set;}
    public Map<String,Set<String>> LinkedIssueByLinkId;
    Jira_ProjectFieldsMapping__c jiraField = new Jira_ProjectFieldsMapping__c();
    Jira_ProjectFieldsMapping__c jiraIssuelInkField=new Jira_ProjectFieldsMapping__c();
    Jira_ProjectFieldsMapping__c issueLinkField = new Jira_ProjectFieldsMapping__c();
    public Boolean hasIssueLinks {get;set;}
    public set<String> issuelinksset {get;set;}
    public integer sizeofli{get;set;}
    public String oldIssueType='';
    
    //new instnaces
    public ID genericObjectID{get;set;}
    String genericObjectName;
    Map<String,String> genericfieldMap=new Map<String,String>();
    Schema.SobjectType ConvertType;
    public  Map<String, String> genericSobjectTypeFieldMap{get;set;} 
    String jiraIssueObjectName;
    public Set<String> mappedObjects{get;set;}
    String parentkey;
    public string tasktype{get;set;}
    Map<String,String> projectSubtaskTypes=new Map<String,String>(); 
    public JiraIssueComments__c comments{get;set;}
    public list<SelectOption> Languages {get;set;}
    /**
*  Constructor, called when used jira is created or edited from any object 
*/
    public ViewJiraIssueController(ApexPages.StandardController controller){
        lang=userinfo.getLanguage();
        Languages = JiraService.LanguageOptions();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        
        comments = new JiraIssueComments__c();
        SizeOfMapLI=0;
        IssueType=FALSE;
        
        if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        
        List<Jira_ProjectFieldsMapping__c> EpicList = [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where Jira_Field_Name__c ='Epic Name' and DataType__c ='gh-epic-label' limit 1];
        
        if(EpicList!= null && EpicList.Size() > 0)
            jiraField = EpicList[0];
        
        List<Jira_ProjectFieldsMapping__c> IssuelinkList = [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where Jira_Field_Name__c ='Parent' and DataType__c ='issuelink' limit 1];
        if(IssuelinkList!= null && IssuelinkList.Size() > 0)
            jiraIssuelInkField = IssuelinkList[0];
        
        
        for (Jira_ProjectFieldsMapping__c issueLinkFields : [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where JIRA_Field_Api_Name__c ='issuelinks' and DataType__c ='issuelinks' limit 1]) {
            issueLinkField = issueLinkFields;
        }
        
        
        
        HasPermission=false;
        
        //FETCH THE JIRA ISSUE ID
        jiraIssueId = controller.getRecord().Id;
        if(controller.getRecord().Id==null){
            jiraIssueId=ApexPages.currentPage().getParameters().get('id');
        }
        
        
        
        //FETCH THE GENERIC OBJECT ID
        
        if(ApexPages.CurrentPage().getparameters().get('genericObjectID')!=null&&
           ApexPages.CurrentPage().getparameters().get('genericObjectID')!='null'&&
           ApexPages.CurrentPage().getparameters().get('genericObjectID')!=''){
               genericObjectID=ApexPages.CurrentPage().getparameters().get('genericObjectID');
               
           }
        
        //FIND OUT THE OBJECT NAME RELATED TO THE GENERIC ID 
        if(genericObjectID!=NULL ){
            genericObjectName=genericObjectID.getSObjectType().getDescribe().getName();
            
        }
        
        //CONVERT THE GENERIC OBJECT NAME TO ITS INSTANCE
        if(genericObjectName!=NULL ){
            ConvertType=Schema.getGlobalDescribe().get(genericObjectName);
            
        }
        
        //CHECK THE PERMISSION OF THE JIRA RELATED OBJECTS
        if(ConvertType!=NULL){
            if(JiraIssue__c.sObjectType.getDescribe().isAccessible() &&
               Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() &&
               Jira_FieldSection__c.sObjectType.getDescribe().isAccessible() &&
               Jira_Project__c.sObjectType.getDescribe().isAccessible() &&
               ConvertType.getDescribe().isAccessible()){
                   if(ApexPages.currentPage().getUrl().tolowercase().contains('editaddjiraissue') &&
                      JiraIssue__c.sObjectType.getDescribe().isCreateable() && JiraIssue__c.sObjectType.getDescribe().isUpdateable() ){
                          HasPermission=true;
                          
                      }else if(ApexPages.currentPage().getUrl().tolowercase().contains('viewjira')){
                          HasPermission=true;    
                      }
               }
        }else{
            
            if(JiraIssue__c.sObjectType.getDescribe().isAccessible() &&
               Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() &&
               Jira_FieldSection__c.sObjectType.getDescribe().isAccessible() &&
               Jira_Project__c.sObjectType.getDescribe().isAccessible()){
                   
                   if(ApexPages.currentPage().getUrl().tolowercase().contains('editaddjiraissue') &&
                      JiraIssue__c.sObjectType.getDescribe().isCreateable() && JiraIssue__c.sObjectType.getDescribe().isUpdateable() ){
                          HasPermission=true;
                          
                      }else if(ApexPages.currentPage().getUrl().tolowercase().contains('viewjira')){
                          HasPermission=true;    
                      }
                   
               }
        }
        //  HasPermission=true;
        
        
        if(!HasPermission){
            errorMessage=System.label.ErrorMsg1_Label;
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(msg);
            return;
        }
        IssueIsEditable=false;
        
        if(jiraIssueId!=null){
            list<UserRecordAccess> Accesslist= new List<UserRecordAccess>();
            Accesslist=[SELECT  RecordId,HasEditAccess  FROM UserRecordAccess where userid=:UserInfo.getUserId() and RecordId=:jiraIssueId];
            if(! Accesslist.isEmpty() ){
                IssueIsEditable=Accesslist[0].HasEditAccess;
            }
            
        }
        
        parentkey = ApexPages.currentPage().getParameters().get('jirakey');
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            setting = [select id,End_Point__c,Default_Jira_Project__c,Username__c from Jira_login__c where name = 'JIRA' LIMIT 1];
        }
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
            if (JiraSalesforceDetail__c.getValues('Edit_Jira_In_SF').value__c.toLowerCase() == 'yes'){
                EditJiraSetting = true;
            } else {
                EditJiraSetting = false;  
            }
        }
        //Function Call
        init();  
    }
    
    Public PageReference LangaugeReset(){
        if(genericObjectID!=NULL){
            //NameSpace removed Grz_Sf__ViewJira to ViewJira
            PageReference pageRef = new PageReference('/apex/ViewJira?jirakey='+parentkey+'&genericObjectID='+genericObjectID+'&id='+jiraIssueId);
            pageRef.setRedirect(true);
            return pageRef;
        }else{
            //NameSpace removed Grz_Sf__ViewJira to ViewJira
            PageReference pageRef = new PageReference('/apex/ViewJira?id='+jiraIssueId);
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    /*********************************************************************
->calls  projectList(),issueTypeList(),priorityList() and usersList()
->dynamicFieldsData gets the fields marked for mapping during admin setup.
->initalize the jiraIssue object  
***********************************************************************/
    public void init(){
        try{
            JiraLogsToInsert = new List<JiraErrorLogs__c>();
            creatableProjects=new set<String>();
            projectIsEditable=false;
            
            sectionorder=new Map<String,List<String>>();
            sectionToDynamicFieldWrapperListMap = new  map<String,list<DynamicFieldWrapper>>();
            sectionToDynamicFieldWrapperListMap2 = new  Map<String,Map<String,List<DynamicFieldWrapper>>>();
            jiraProjectskeymap=new map<String,String>();
            ProjectkeyToObjectmap =new Map<String, Jira_Project__c>();
            Map<String,Schema.SObjectField>  genericFieldMapTemp;
            DynamicFieldWrapperList =new list<DynamicFieldWrapper>();
            Set<String> subtaskProjects=new Set<String>();
            
            //FETCH THE JIRA PROJECTS AND CREATE A MAP 
            if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
                for(Jira_Project__c project:[select id,Name,ProjectKey__c,ProjectId__c,Read__c, DefaultIssueType__c, IssueType__c,Subtask__c, Write__c from Jira_Project__c LIMIT 1000]){
                    if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                        ProjectkeyToObjectmap.put(project.ProjectKey__c,project);
                    }
                    if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible() && Schema.sObjectType.Jira_Project__c.fields.id.isAccessible()){
                        jiraProjectskeymap.put(project.ProjectKey__c,project.id);
                    }
                    if(project.Write__c && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                        creatableProjects.add(project.ProjectKey__c);
                    }
                    if(project.Subtask__c!=NULL && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                        subtaskProjects.add(project.ProjectKey__c);
                        
                        if(!projectSubtaskTypes.containskey(project.ProjectKey__c) && Schema.sObjectType.Jira_Project__c.fields.Subtask__c.isAccessible())
                            projectSubtaskTypes.put(project.ProjectKey__c,project.Subtask__c);
                    }
                    
                }
                
            }
            //CREATE A MAP OF FIELDS OF GENERIC OBJECT
            if(ConvertType!=NULL)
                genericFieldMapTemp=ConvertType.getDescribe().fields.getMap();
            
            
            
            //CREATE A MAP OF GENERIC OBJECT FIELDS TO ITS DATATYPE
            if(genericFieldMapTemp!=NULL){
                
                for(String cs:genericFieldMapTemp.keyset()){
                    genericfieldMap.put(String.valueof(genericFieldMapTemp.get(cs)),String.valueof(genericFieldMapTemp.get(cs).getDescribe().getType()));
                    
                }
            }
            
            
            List<JiraIssue__c> jiraIssueList=new List<JiraIssue__c>();
            ID getobjectID;
            
            //FETCH THE JIRA ISSUE RECORD
            if(jiraIssueId!=NULL && JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                jiraIssueList =  new List<JiraIssue__c>([Select Id,Name, Summary__c,Creator__c,Resolution__c,ResolutionDate__c,CaseNos__c,Description__c, Jira_Link__c, IssueType__c, Project__c, IssueId__c, IssueKey__c, Created__c, Updated__c, Status__c, Priority__c, Reporter__c, Assignee__c,JsonData__c, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById,LastModifiedBy.name,CreatedBy.name from JiraIssue__c where Id = :jiraIssueId]);
            }
            
            //FInd out the object name from the ID 
            
            
            
            //IF JIRA ISSUE IS NULL THEN CREATE NEW ISSUE
            jiraIssue = (jiraIssueList!=null && jiraIssueList.size()>0)?jiraIssueList.get(0):new JiraIssue__c() ;
            
            Set<String> subtype=new set<String>();
            
            if(projectSubtaskTypes.containsKey(jiraIssue.Project__c) && Schema.sObjectType.JiraIssue__c.fields.Project__c.isAccessible()){
                List<String> Subtasktypes=projectSubtaskTypes.get(jiraIssue.Project__c).split(',');
                
                subtype.addAll(Subtasktypes);
                //if(subtype.contains(jiraIssue.IssueType__c))
                //  tasktype='true';
            }
            
            
            if(subtaskProjects.contains(jiraIssue.Project__c) && !subtype.contains(jiraIssue.IssueType__c))
            {
                Issuetype=true;
            }
            
            //CHECK IF JIRA PROJECT IS AVAILABLE AND SHOW ON THE  DETAIL PAGE 
            if(Schema.sObjectType.JiraIssue__c.fields.Project__c.isAccessible()){
                projectName  = jiraIssue.Project__c; 
            }
            ProjectAvailable= jiraProjectskeymap.containsKey(projectName);
            
            
            
            if(!ProjectAvailable){
                errorMessage=System.label.TheJiraProject_Label +jiraIssue.Project__c+ System.label.Label_ErrorMsg;
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
                ApexPages.addMessage(msg);
                return; 
            }
            
            projectIsEditable= creatableProjects.contains(projectName); 
            
            
            
            Map<String,Jira_ProjectFieldsMapping__c> dynamicFieldsDataMap=new Map<String,Jira_ProjectFieldsMapping__c>();
            List<JiraRelationship__c> jiraRelationList=new  List<JiraRelationship__c>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            //FETCH THE PROJECT FIELD MAPPING RECORDS BASED ON GENERIC OBJECT OF ALL RECORDS 
            if(genericObjectName!='' && genericObjectName !=NULL){
                Schema.DescribeSObjectResult dls=schemaMap.get(genericObjectName).getDescribe();
                mappedObjects=new Set<String>(); 
                mappedObjects.add(dls.getLabel());
                relatedObjectsToJiraIssue=new Set<String>();
                
                
                if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
                    dynamicFieldsData = [SELECT Id,IsStatic__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,  ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Subtask__c,Jira_Project__r.Projectkey__c,  Jira_Field_Name__c , section__c,Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c, section__r.name,Salesforce_Object__c  FROM  Jira_ProjectFieldsMapping__c where Jira_Project__r.Projectkey__c=:projectName AND Salesforce_Object__c=:genericObjectName order by section__r.order__c,order__c Asc nulls last  limit 1000];
                }
                
                if(dynamicFieldsData.size()>0 && dynamicFieldsData!=NULL)
                    relatedObjectsToJiraIssue.add(dls.getLabel());
                
                
                objectsLabelList=new Set<String>();
                for(String str :relatedObjectsToJiraIssue){
                    objectsLabelList.add(str);
                }
                
                If(dynamicFieldsData==NULL || dynamicFieldsData.isEmpty()){
                    
                    errorMessage=System.label.ViewJiraIssueController_Label4 +genericObjectName+ System.label.ViewJiraIssueController_Label5;
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(msg);
                    return; 
                    
                }
                
                //create a set of Jira Project Field Mapping 
                for(Jira_ProjectFieldsMapping__c  field : dynamicFieldsData){
                    
                    
                    if(!dynamicFieldsDataMap.containsKey(field.Name)){
                        dynamicFieldsDataMap.put(field.Name,field);
                        
                    }
                }
                
                //CREATE THE DYNAMIC FIELD WRAPPER LIST
                for(Jira_ProjectFieldsMapping__c field : dynamicFieldsDataMap.values()){
                    
                    DynamicFieldWrapperList.add(new DynamicFieldWrapper(field,tasktype));
                }
                
            }else{
                
                
                
                
                map<String,Schema.SObjectField>  genericFieldMap = new map<String,Schema.SObjectField>();
                map<String,Schema.SObjectField>  NewgenericFieldMap = new map<String,Schema.SObjectField>();  
                //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                genericFieldMap= schemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
                
                for(String key:genericFieldMap.keySet()){
                    String Inkey=key.tolowerCase();
                    Inkey=Inkey.remove('grz_sf__');
                    NewgenericFieldMap.put(Inkey,genericFieldMap.get(key));
                }
                
                String dynamicquery='';
                
                for(String str:NewgenericFieldMap.keySet()){
                    
                    if(dynamicquery==''){
                        dynamicquery=str;   
                    }
                    else{
                        dynamicquery+= ','+Str ;
                    }
                }
                
                string query='SELECT '+dynamicquery+ ' FROM JiraRelationship__c WHERE JiraIssue__c=:jiraIssueId';
                if(JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
                    jiraRelationList=Database.Query(query);   
                }
                
                Map<String,String> genericfieldTypeMap=new Map<String,String>();
                
                for(String str:NewgenericFieldMap.KeySet()){
                    
                    genericfieldTypeMap.put(String.ValueOf(NewgenericFieldMap.get(str)),String.valueof(NewgenericFieldMap.get(str).getDescribe().getType()));
                }
                
                relatedObjectsToJiraIssue=new Set<String>();
                
                for(JiraRelationship__c JR: jiraRelationList){
                    
                    JiraRelationship__c JRinstance=JR;
                    
                    
                    for(String str:genericfieldTypeMap.keySet()){
                        
                        if(genericfieldTypeMap.get(str)=='reference' && str.contains('Relation__c')){
                            
                            
                            if(JRinstance.get(str)!=null){
                                
                                ID relationID=String.valueOf(JRinstance.get(str));
                                String objname= relationID.getSObjectType().getDescribe().getName();
                                
                                if(!relatedObjectsToJiraIssue.contains(objname))
                                    relatedObjectsToJiraIssue.add(objname);
                            }
                        }
                    } 
                }   
                
                if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
                    dynamicFieldsData = [SELECT Id,IsStatic__c,Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,  ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Subtask__c,Jira_Project__r.Projectkey__c,  Jira_Field_Name__c , section__c,Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c, section__r.name,Salesforce_Object__c FROM  Jira_ProjectFieldsMapping__c where Jira_Project__r.Projectkey__c=:projectName AND Salesforce_Object__c IN:relatedObjectsToJiraIssue order by section__r.order__c,order__c Asc nulls last  limit 1000];
                }
                objectsLabelList=new Set<String>();
                for(String str :relatedObjectsToJiraIssue){
                    Schema.DescribeSObjectResult dls=schemaMap.get(str).getDescribe();
                    objectsLabelList.add(dls.getLabel());
                }
                
                If(dynamicFieldsData.isEmpty() && dynamicFieldsData==NULL){
                    
                    errorMessage=System.label.ViewJiraIssueController_Label4 +relatedObjectsToJiraIssue +System.label.ViewJiraIssueController_Label5;
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(msg);
                    return; 
                    
                }
                
                mappedObjects=new Set<String>(); 
                //CREATE THE DYANMIC FIELD WRAPPER LIST
                for(Jira_ProjectFieldsMapping__c field : dynamicFieldsData){
                    
                    Schema.DescribeSObjectResult dls=schemaMap.get(field.Salesforce_Object__c).getDescribe();
                    
                    if(!mappedObjects.contains(dls.getLabel()))
                        mappedObjects.add(dls.getLabel());
                    
                    DynamicFieldWrapperList.add(new DynamicFieldWrapper(field,tasktype));
                    
                }
                
            }
            
            //fetch the jira data while viweing the JIRA Issue Record
            CreateJiraData();
            
            if(objectsLabelList.size()>0 && objectsLabelList!=NULL){
                
                for(string obj: objectsLabelList){
                    
                    if(!mappedObjects.contains(obj)){
                        objectsLabelList.remove(obj);
                    }
                }
            }
            
            sizeofli= objectsLabelList.size();
            
            //Show the feids on the Edit Add Jira Page; 
            LeftOverDataToLoadPage();
            
            
        }catch(Exception ex){ 
            String Errormsg=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraIssueController',null, null, null, null,null, null , null, null, 'init', Errormsg));
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Errormsg);
            ApexPages.addMessage(msg);
        }
    }
    
    /**********************************************
fetch the jira Issue record to viwe on viewJIra Page
***********************************************/
    public void CreateJiraData(){
        
        if(jiraIssue!=Null && jiraIssue.JsonData__c!=Null){
            
            Map<String, Object> JsonData = (Map<String, Object>) JSON.deserializeUntyped(jiraIssue.JsonData__c);
            
            for(DynamicFieldWrapper dynamic:DynamicFieldWrapperList){
                
                String Jsonfield=dynamic.mappedField.JIRA_Field_Api_Name__c;
                
                String Value= FieldJsonHelper.getFieldData(Jsonfield,JsonData);
                String issue_Key= jiraIssue.IssueKey__c;
                
                if((Value!=Null && Value !='' && Value !='null') || Jsonfield=='issuelinks'){
                    
                    
                    String FieldType=dynamic.mappedField.DataType__c;
                    
                    if(dynamic.mappedField.IsArray__c || dynamic.mappedField.DataType__c=='version'){
                        
                        if(FieldType.toLowerCase()=='cascadingselect' ){
                            dynamic.masterFieldValue=dynamic.clubMasterMapRev.get(value);
                            if(value.contains('_child_')){
                                list<String> DepValue=value.split('_child_');
                                dynamic.childFieldValue=DepValue[1]; 
                                dynamic.masterFieldValue=DepValue[0];
                                
                            }
                        }
                        else if(FieldType.toLowerCase()=='labels'||FieldType.toLowerCase()=='string' ||FieldType.toLowerCase()=='textarea' ||FieldType.toLowerCase()=='textfield'){
                            value=value.replace(',',' ');
                            dynamic.fieldValue=value;
                        }else if((FieldType.toLowerCase()=='version' && !dynamic.mappedField.IsArray__c)||FieldType.toLowerCase()=='select' || FieldType.toLowerCase()=='radiobuttons'){
                            if(dynamic.mappedField.jira_field_api_name__c=='assignee' && (value ==null ||value=='')){
                                dynamic.fieldValue='Unassigned';
                            }else{
                                
                                value=value.removeEnd(',');
                                dynamic.fieldValue=value;
                                
                            }
                        }else if( FieldType.toLowerCase()=='userpicker'||
                                 FieldType.toLowerCase()=='user'  ){
                                     map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
                                     
                                     if(JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c)!=null){
                                         Map<String,Object> MapofUserdetail = (Map<String,Object>)JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c);
                                         dynamic.username =(String)MapofUserdetail.get('displayName')+' - '+(String)MapofUserdetail.get('emailAddress')+' ('+(String)MapofUserdetail.get('key')+')';
                                         dynamic.usermapFinal.put(dynamic.username,String.valueof(MapofUserdetail.get('displayName')));
                                     } 
                                     dynamic.fieldValue=value;
                                     if(dynamic.mappedField.jira_field_api_name__c=='assignee' && (value ==null ||value=='')){
                                         dynamic.fieldValue='Unassigned';
                                     }else{
                                         
                                         value=value.removeEnd(',');
                                         dynamic.fieldValue=value;
                                     }
                                 }else if(FieldType.toLowerCase()=='multiuserpicker'){
                                     //modified on 01-07-2019
                                     map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
                                     dynamic.fieldValue='';
                                     if(JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c)!=null){
                                         List<Object> ListOFuserObject=(List<Object>) JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c);
                                         for(Object UserObj:ListOFuserObject){
                                             Map<String,Object> MapofUserdetail  = (Map<String,Object>)UserObj;
                                             String Mapkey=(String)MapofUserdetail.get('displayName')+' - '+(String)MapofUserdetail.get('emailAddress')+' ('+(String)MapofUserdetail.get('key')+')';
                                             dynamic.usermapFinal.put(Mapkey,String.valueof(MapofUserdetail.get('displayName')));
                                             dynamic.fieldValue=dynamic.fieldValue==''?(String)MapofUserdetail.get('displayName'):(dynamic.fieldValue+', '+(String)MapofUserdetail.get('displayName'));
                                                 }
                                     } 
                                 }else if(FieldType.toLowerCase()=='multiversion'||FieldType.toLowerCase()=='multiselect'||FieldType.toLowerCase()=='multicheckboxes'||FieldType.toLowerCase()=='version'||FieldType.toLowerCase()=='component'){
                                     
                                     list<String> ValueList= Value.split(',');
                                     Value='';
                                     
                                     for(String Temp: ValueList){
                                         for(String Selectvalue:dynamic.selectValueMap.keyset()){
                                             if(Temp!=null && Temp.toLowerCase()==(dynamic.selectValueMap.get(Selectvalue).toLowerCase())){
                                                 dynamic.multiselectvalues.add(Selectvalue);
                                                 /*if(jiraIssue.Project__c !=Null){
dynamic.mappedField.RelatedProjectIdSet__c =jiraProjectskeymap.get(jiraIssue.Project__c);
}*/
                                             }
                                         }
                                     }
                                     value=value.removeEnd(';');
                                     dynamic.fieldValue=value;
                                 }else if(FieldType.toLowerCase()=='issuelinks'){
                                     IssuelinksMap = New Map<String,List<FieldJsonHelper.LinkedIssues>>();    
                                     HttpRequest req = new HttpRequest(); 
                                     Http http = new Http();
                                     HTTPResponse res;
                                     if(issueLinkField.JIRA_Field_Api_Name__c != null){
                                         
                                         
                                         req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+issue_Key+'?fields='+issueLinkField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                         res =http.send(req); 
                                         if(res.getStatusCode()==200){
                                             Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                             IssuelinksMap = FieldJsonHelper.getIssueLinkData(issueLinkField.JIRA_Field_Api_Name__c,EpicJsonData);
                                             dynamic.fieldValue= null;
                                             SizeOfMapLI = IssuelinksMap.size();
                                         }else{
                                             JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraIssueController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null , null, null,'CreateJiraData', res.getBody()));
                                             
                                         }
                                     }
                                 }
                        
                    }else{
                        
                        if(FieldType.toLowerCase()=='gh-epic-label'||FieldType.toLowerCase()=='gh-epic-link'||FieldType.toLowerCase()=='float'||FieldType.toLowerCase()=='textfield'||FieldType.toLowerCase()=='string'||FieldType.toLowerCase()=='textarea'||FieldType.toLowerCase()=='issuelink'){
                            if(dynamic.mappedField.Jira_Field_api_Name__c.toLowerCase()=='resolutiondate'){
                                
                                dynamic.fieldValue=EditAddJiraIssueController.ConvertDate(value);
                            }
                            else if(FieldType.toLowerCase()=='issuelink'){
                                
                                HttpRequest req = new HttpRequest(); 
                                Http http = new Http();
                                HTTPResponse res;
                                
                                if(jiraIssuelInkField.JIRA_Field_Api_Name__c != null && parentkey!=NULL && parentkey!=''){
                                    
                                    req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+parentkey+'?fields='+jiraIssuelInkField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                    
                                    res =http.send(req); 
                                    if(res.getStatusCode()==200){
                                        Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        parents = FieldJsonHelper.getFieldData(jiraIssuelInkField.JIRA_Field_Api_Name__c,EpicJsonData);
                                        
                                        dynamic.fieldValue= parents;
                                        parentIssueId=new List<JiraIssue__c>();
                                        if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                                            parentIssueId=[select id from JiraIssue__c where IssueKey__c =:parents];
                                        }
                                        if(Schema.sObjectType.JiraIssue__c.fields.id.isAccessible() && parentIssueId.size()>0 && parentIssueId!=NULL)
                                            SubtaskParentID=parentIssueId[0].id;
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraIssueController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null , null, null,'CreateJiraData', res.getBody()));
                                        
                                    }
                                }
                            }
                            else{
                                dynamic.fieldValue=Value;
                                
                            }
                            
                            if(FieldType.toLowerCase()=='gh-epic-link'){
                                HttpRequest req = new HttpRequest(); 
                                Http http = new Http();
                                HTTPResponse res;
                                
                                if(jiraField.JIRA_Field_Api_Name__c != null){
                                    req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+Value+'?fields='+jiraField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                    res =http.send(req); 
                                    if(res.getStatusCode()==200){
                                        Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        epicKey = FieldJsonHelper.getFieldData(jiraField.JIRA_Field_Api_Name__c,EpicJsonData);
                                        dynamic.fieldValue= Value;
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraIssueController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null , null, null,'CreateJiraData', res.getBody()));
                                        
                                    }
                                }
                            }                                    
                        }else if(FieldType.toLowerCase()=='datepicker'){
                            dynamic.datevalue=value;
                            
                        }else if(FieldType.toLowerCase()=='datetime'){
                            String dt='';
                            
                            dt= Value;
                            dt=dt.replace('T',' ');
                            
                            dynamic.datetimevalue=dt;
                            
                        }
                        
                        
                    } 
                    
                }  
                
            }
            
        }
    }
    
    /*******************************************
This Function loads the fields on the page
*******************************************/
    public void LeftOverDataToLoadPage(){
        
        for(DynamicFieldWrapper Dfield : DynamicFieldWrapperList){
            
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult dls=schemaMap.get(Dfield.mappedField.Salesforce_Object__c).getDescribe();
            
            
            if(sectionToDynamicFieldWrapperListMap2.ContainsKey(dls.getLabel())){
                
                Map<String,List<DynamicFieldWrapper>> tempMap=sectionToDynamicFieldWrapperListMap2.get(dls.getLabel());
                
                if(tempMap.containsKey(Dfield.mappedField.Section__r.Name)){
                    
                    tempMap.get(Dfield.mappedField.Section__r.Name).add(Dfield);
                    sectionToDynamicFieldWrapperListMap2.put(dls.getLabel(),tempMap);
                    
                    
                }else{
                    
                    tempMap.put(Dfield.mappedField.Section__r.Name,new list<DynamicFieldWrapper>{Dfield});
                    //SectionOrder.add(Dfield.mappedField.Section__r.Name);
                    List<String> tempsection=SectionOrder.get(dls.getLabel());
                    tempsection.add(Dfield.mappedField.Section__r.Name);
                    
                    object objName=Dfield.mappedField.Salesforce_Object__c;
                    SectionOrder.put(dls.getLabel(),tempsection);
                    sectionToDynamicFieldWrapperListMap2.put(Dfield.mappedField.Salesforce_Object__c,tempMap);
                }
                
            }else{
                
                List<DynamicFieldWrapper> dfw=new  List<DynamicFieldWrapper>{Dfield};
                    //SectionOrder.add(Dfield.mappedField.Section__r.Name);
                    SectionOrder.put(dls.getLabel(),new List<String>{Dfield.mappedField.Section__r.Name});
                sectionToDynamicFieldWrapperListMap2.put(dls.getLabel(),new Map<String,List<DynamicFieldWrapper>> {Dfield.mappedField.Section__r.Name=>dfw});
                
                
            } 
            if(Dfield.mappedField.name=='Issue Type' && Dfield.mappedField.Jira_Project__r.Projectkey__c==projectname ){
                if(!Dfield.selectValues.isEmpty() && jiraIssue !=null && jiraIssue.IssueType__c ==null){
                    
                    for(SelectOption key: Dfield.selectValues){
                        String defaultIssueType = ProjectkeyToObjectmap.get(projectname).DefaultIssueType__c;
                        if (defaultIssueType != null) {
                            jiraIssue.IssueType__c = defaultIssueType;
                            
                        }else{
                            jiraIssue.IssueType__c='Epic';
                            break;
                        }
                    }
                }
            }
            
            
           
            
            
        }
    }
    
    public void deleteLink(){
        
        String keytoDelete = ApexPages.currentPage().getParameters().get('key');
        String LinkType = ApexPages.currentPage().getParameters().get('linktype');
        HttpRequest req = new HttpRequest(); 
        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issueLink/'+ keytoDelete,'DELETE','application/json');   
        Http http = new Http();
        HTTPResponse res;
        try {
            
            res = http.send(req);
            
            if(res.getStatusCode()== 204 ){
                if(!IssuelinksMap.isEmpty() && IssuelinksMap.ContainsKey(LinkType) && IssuelinksMap.get(LinkType)!= null){
                    list<FieldJsonHelper.LinkedIssues> ListoPut = New List<FieldJsonHelper.LinkedIssues>();
                    List<FieldJsonHelper.LinkedIssues> LiList = IssuelinksMap.get(LinkType);
                    if(!LiList.isEmpty()){
                        For(FieldJsonHelper.LinkedIssues LI : LiList){
                            If(LI!= null && LI.Id != keytoDelete){
                                ListoPut.add(LI);
                            }
                        }
                    }
                    if(!IssuelinksMap.get(LinkType).isEmpty() && LiList.size() == 1){
                        IssuelinksMap.remove(LinkType);
                    }
                    else{
                        IssuelinksMap.put(LinkType,ListoPut);
                    } 
                }
            }else{
                GenerateJiraLogs.CreateLogRealTime('ViewJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Delete Link', res.getbody());
                
            }
            if(!IssuelinksMap.isEmpty()){
                SizeOfMapLI = IssuelinksMap.size();
            }else{
                SizeOfMapLI = 0;
            }
            
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('ViewJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Delete Link', Error);
            
        }
    }
    
    Public Pagereference Redirectt()
    {   
        
        Id id1 =ApexPages.currentPage().getParameters().get('id');
        String jirakey = ApexPages.currentPage().getParameters().get('jirakey');
        string genericObjectID = ApexPages.currentPage().getParameters().get('genericObjectID');
        string lg = ApexPages.currentPage().getParameters().get('lg');
        jiraIssue__c j1=new jiraIssue__c();
        if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
            j1 = [SELECT Id, IssueId__c FROM JiraIssue__c WHERE Id =: Id1 LIMIT 1];
        }
        
        if(j1!=NULL && ContentDocumentLink.sObjectType.getDescribe().isAccessible()){
            for(ContentDocumentLink c: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:j1.Id])
            { 
                Ids.add(c.ContentDocumentId);
            }
        }
        Pagereference pageref=new pagereference('/apex/SyncCommentsAttachmentsToJira?id='+id1+'&genericObjectID='+genericObjectID+'&jirakey='+jirakey);
        pageref.setRedirect(true);
        return pageref;
        
        
        
        
    }
    
    Public Pagereference Subtask(){
        
        
        Id id1 =ApexPages.currentPage().getParameters().get('id');
        JiraIssue__c j1=new JiraIssue__c();
        if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
            j1 = [SELECT Id, IssueId__c,IssueKey__c FROM JiraIssue__c WHERE Id =: Id1 LIMIT 1];
        }
        Pagereference pageref=new pagereference('/apex/EditAddJiraIssue?genericObjectID='+genericObjectID +'&subtask=true'+'&key=' + j1.IssueKey__c);
        pageref.setRedirect(true);
        return pageref;
        
        
    }
    
    public PageReference   deletelinkedjira(){
        return null;
    }
    public PageReference addComment(){
        if(schema.sObjectType.JiraIssueComments__c.fields.JiraIssue__c.isCreateable()){
            
            comments.JiraIssue__c=jiraIssueId;
        }
        try{
            if(schema.sObjectType.JiraIssueComments__c.isCreateable()){
                if(comments.CommentBody__c!=null && comments.CommentBody__c.trim()!=''){
                    insert comments;
                }
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('ViewJiraIssueController',null, null, null,null,null, null , null, jiraIssueId, 'Add Comment', Error);
            
        }
        
        PageReference pageref=new PageReference('/apex/ViewJira?jirakey='+jiraissue.IssueKey__c+'&genericObjectID='+genericObjectID+'&id='+jiraIssueId);
        pageref.setRedirect(true);
        return pageref;
    }
    public void InsertJiraLogs(){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}