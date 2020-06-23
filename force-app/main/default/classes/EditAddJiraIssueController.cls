global with sharing class EditAddJiraIssueController {
    public List<JiraErrorLogs__c> JiraLogsToInsert; 
    Map<String,String> accoundIdTouserAccount=new map<String,String>();
    public List<Object> userdetail{get;set;} 
    public string displayname {get;set;}
    public string name {get;set;}
    public string emailaddress {get;set;}
    public List<Object>userdata {get;set;}
    public Map<String,Set<String>> IssuelinksMapValue {get;set;}
    public boolean projectSelected{get;set;}
    final String JIRA_DATE_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    Jira_ProjectFieldsMapping__c jiraIssuelInkField=new Jira_ProjectFieldsMapping__c();
    public Boolean mapNotEmpty{get;set;}
    public Case caseObject {get; set;} 
    public Sobject caseObject2 {get; set;} 
    public Sobject dynamicObjectType {get; set;}
    public string subtask{get;set;}
    public string projectName {get; set;}
    public string casenumber;
    public list<String>genericobjname;
    public static Set<String> jiraIssueKeySet ;
    public string tasktype{get;set;}
    public String jiraIssueKey { get; set; }
    public String parents { get;set;}
    public Id caseId {get; set;}
    
    public Id jiraIssueId {get; set;}
    //public Id JiraIssueUrlId1;
    public List<SelectOption> issueTypes {get; set;}
    
    public List<SelectOption> priority {get; set;}
    
    public List<SelectOption> projects {get; set;}
    
    public List<SelectOption> userList {get; set;}
    
    public List<SelectOption> statusList {get; set;}
    
    public JiraIssue__c jiraIssue {get; set;}
    public String usersearchtext{get;set;}
    // public map<String,list<DynamicFieldWrapper>> sectionToDynamicFieldWrapperListMap{get; set;}
    public map<String,Map<Integer,Map<String,DynamicFieldWrapper>>> sectionToDynamicFieldWrapperListMap{get; set;}
    
    
    public List<String> sectionorder{get; set;} 
    //public String caseNumberApi;
    public String keytoDelete {get;set;}
    public Map<String, Jira_Project__c> jiraProjectsMap;
    
    public Map<String, Map<String,String>> dynamicFieldsMap {get; set;}
    
    public Map<String, Jira_ProjectFieldsMapping__c> dynamicFieldsDataMap {get; set;}
    public List<Jira_ProjectFieldsMapping__c > dynamicFieldsData;
    public list<DynamicFieldWrapper> DynamicFieldWrapperList{get;set;}
    //public  Map<String, String> casefieldMap{get;set;}
    private Map<String, String> issueTypeMap;
    public list<Jira_Project__c>jiraProjectsList;
    public Map<String, String> jiraProjectskeymap{get;set;} 
    public Map<String, String> priorityNameMap;
    public Boolean isDefault{get;set;}
    public Boolean HasRuleset{get;set;}
    public String errorMessage{get;set;}
    public String Reporter{get;set;}
    public list<JiraIssue__c> searchJiraIssueList{get;set;}
    //public map<String,String>projectversionmap{get;set;}
    public string mode{get;set;}
    public string modetype{get;set;}
    public String clonedid;
    public Boolean ProjectAvailable{get;set;}
    public Boolean IssueIsEditable{get;set;}
    public String RelatedList1{get;set;}
    public Set<String> creatableProjects{get;set;}
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
    Jira_ProjectFieldsMapping__c issueLinkField = new Jira_ProjectFieldsMapping__c();
    public Boolean hasIssueLinks { get;set;}
    public set<String> issuelinksset {get;set;}
    public integer sizeofli{get;set;}
    public String oldIssueType='';
    public String subtaskParentID{get;set;}
    //new instnaces
    public ID genericObjectID{get;set;}
    // String genericObjectName;
    public String genericObjectName{get;set;}
    Schema.SobjectType ConvertType;
    Map<String,String> genericfieldMap=new Map<String,String>();
    public  Map<String, String> genericSobjectTypeFieldMap{get;set;} 
    public date x_date{get;set;}
    public Datetime y_data{get;set;}
    Datetime dt;
    public String key{get;set;}
    public String lang{get;set;}
    Map<String,String> projectSubtaskTypes=new Map<String,String>(); 
    public list<SelectOption> Languages {get;set;}

    /**
*  Constructor, called when used jira is created or edited from any object 
*/
    public EditAddJiraIssueController(ApexPages.StandardController controller){
        lang=userinfo.getLanguage();
        Languages = JiraService.LanguageOptions();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
      
        mapNotEmpty=false;
        projectSelected=false;
        HasRuleset=false;
        SizeOfMapLI = 0;
        issuelinksset = new Set<String>();
        IssuelinksMapValue=new Map<String,Set<String>>();
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            List<Jira_ProjectFieldsMapping__c> EpicList = [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where Jira_Field_Name__c ='Epic Name' and DataType__c ='gh-epic-label' limit 1];
            if(EpicList!= null && EpicList.Size() > 0)
                jiraField = EpicList[0];
            
            List<Jira_ProjectFieldsMapping__c> IssuelinkList = [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where Jira_Field_Name__c ='Parent' and DataType__c ='issuelink' limit 1];
            if(IssuelinkList!= null && IssuelinkList.Size() > 0)
                jiraIssuelInkField = IssuelinkList[0];
            for (Jira_ProjectFieldsMapping__c issueLinkFields : [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where JIRA_Field_Api_Name__c ='issuelinks' and DataType__c ='issuelinks' limit 1]) {
                issueLinkField = issueLinkFields;
            }
        }
        
        
        HasPermission=false;
        
        //fetch the generic Object Id
        genericObjectID=ApexPages.CurrentPage().getparameters().get('genericObjectID');
        
        
        //fetch the Object Name 
        if(genericObjectID!=NULL){
            genericObjectName=genericObjectID.getSObjectType().getDescribe().getName();
        }
        
        //Convert the String to the Sobject Type
        if(genericObjectName!=NULL ){
            ConvertType=Schema.getGlobalDescribe().get(genericObjectName);
        }
        
        //fetch the jira Issue Id
     
        if(controller.getRecord().Id==null){
            jiraIssueId=ApexPages.currentPage().getParameters().get('id');
            
        }else{
            jiraIssueId = controller.getRecord().Id;
        }
        
        if(jiraIssueId!=NULL){ 
            projectSelected=true;
        }
        mode = Apexpages.currentPage().getParameters().get('mode')!=null?Apexpages.currentPage().getParameters().get('mode'):'';
        if(mode.contains('clone')){
            modetype='clone';
            isDefault=true;
        }
        
        
        /* if(jiraIssueId!=null){
list<UserRecordAccess> Accesslist= new List<UserRecordAccess>();
Accesslist=[SELECT RecordId,HasEditAccess  FROM UserRecordAccess where userid=:UserInfo.getUserId() and RecordId=:jiraIssueId];
if(! Accesslist.isEmpty() ){
IssueIsEditable=Accesslist[0].HasEditAccess;
} 
}*/
        
        
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
        
        
        if(!HasPermission){
            errorMessage=System.label.ErrorMsg1_Label;
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(msg);
            return;
        }
        
        subtask = Apexpages.currentPage().getParameters().get('subtask')!=null?Apexpages.currentPage().getParameters().get('subtask'):'';
        if(subtask.contains('true')){
            tasktype= 'true';
        }
        
        key = Apexpages.currentPage().getParameters().get('subtask')!=null?Apexpages.currentPage().getParameters().get('key'):'';
        
       
        projectName='';
        if(!mode.contains('clone') && jiraIssueId==null && subtask!='true'){
            
            if(genericObjectName !=''  && genericObjectID!=NULL){
                projectName=RuleSetProject.getProjectName(genericObjectID);
                if(projectName!='' && projectName!=null){
                    HasRuleset=true;
                    
                }
            }
            if((projectName==null||projectName=='') && Schema.sObjectType.JiraSalesforceDetail__c.fields.Value__c.isAccessible() ){
                projectName = JiraSalesforceDetail__c.getValues('DefaultProject')!=null? JiraSalesforceDetail__c.getValues('DefaultProject').Value__c!=null? JiraSalesforceDetail__c.getValues('DefaultProject').Value__c:'':'';
            }
        }
       
        if(projectName!=null&&projectName!=''){
            projectSelected=true;
        }
        
      
        //This Function intialises the fields of the Object 
        init();  
    }
    
    Public PageReference LangaugeReset(){
     
        if(jiraIssueId==NULL){
            //NameSpace removed Grz_Sf__EditAddJiraIssue to EditAddJiraIssue
            PageReference pageRef = new PageReference('/apex/EditAddJiraIssue?genericObjectID='+genericObjectID);
            pageRef.setRedirect(true);
            return pageRef;  
        }else{
            //NameSpace removed Grz_Sf__EditAddJiraIssue to EditAddJiraIssue
            PageReference pageRef = new PageReference('/apex/EditAddJiraIssue?id='+jiraIssueId+'&genericObjectID='+genericObjectID);
          
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
            hasIssueLinks =false;
            sectionorder = new List<string>();
            creatableProjects=new set<String>();
            sectionToDynamicFieldWrapperListMap = new map<String,Map<Integer,Map<String,DynamicFieldWrapper>>>();
            jiraProjectsList = new list<Jira_Project__c>();
            jiraProjectskeymap=new map<String,String>();
            ProjectkeyToObjectmap =new Map<String, Jira_Project__c>();
            Set<String> subtaskProjects=new Set<String>();
            //FETCH ALL THE JIRA PROJECTS LIST AND CREATE A MAP
            if(Jira_Project__c.sObjectType.getDescribe().isAccessible() ){
                for(Jira_Project__c project:[select id,Name,ProjectKey__c,ProjectId__c,Read__c, DefaultIssueType__c, IssueType__c, Write__c,Subtask__c from Jira_Project__c LIMIT 10000]){
                    jiraProjectsList.add(project);
                    if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                        ProjectkeyToObjectmap.put(project.ProjectKey__c,project);
                    }
                    if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible() && Schema.sObjectType.Jira_Project__c.fields.id.isAccessible()){
                        jiraProjectskeymap.put(project.ProjectKey__c,project.id);
                    }
                    if(project.Write__c){
                        if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                            creatableProjects.add(project.ProjectKey__c);
                        }
                    }
                    if(project.Subtask__c!=NULL){
                        if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                            subtaskProjects.add(project.ProjectKey__c);
                        }
                    }
                    if(Schema.sObjectType.Jira_Project__c.fields.Subtask__c.isAccessible() && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                        if(!projectSubtaskTypes.containskey(project.ProjectKey__c) && project.Subtask__c!=NULL){
                            projectSubtaskTypes.put(project.ProjectKey__c,project.Subtask__c);
                        }
                    }
                }
            }
            
            
            map<String,Schema.SObjectField>  genericFieldMapTemp;
            
            //BUILD A MAP OF FIELDS OF THE GENERIC OBJECT
            if(ConvertType!=NULL)
                genericFieldMapTemp=ConvertType.getDescribe().fields.getMap();
            
            
            
            //create a map of field name to its type
            if(genericFieldMapTemp!=NULL){
                for(String cs:genericFieldMapTemp.keyset()){
                    genericfieldMap.put(String.valueof(genericFieldMapTemp.get(cs)),String.valueof(genericFieldMapTemp.get(cs).getDescribe().getType()));
                    
                    
                    
                }
            }
            
            
            Set<String> fields = new Set<String>();
            List<JiraIssue__c> jiraIssueList =new List<JiraIssue__c>();
            
            if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                jiraIssueList =  new List<JiraIssue__c>([Select Id,Name, Summary__c,Creator__c,Resolution__c,ResolutionDate__c,CaseNos__c,Description__c, Jira_Link__c, IssueType__c, Project__c, IssueId__c, IssueKey__c, Created__c, Updated__c, Status__c, Priority__c, Reporter__c, Assignee__c,JsonData__c, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById,LastModifiedBy.name,CreatedBy.name from JiraIssue__c where Id = :jiraIssueId]);
            }
            
            jiraIssue = (jiraIssueList!=null && jiraIssueList.size()>0)?jiraIssueList.get(0):new JiraIssue__c() ;
            
            
            if(Schema.sObjectType.JiraIssue__c.fields.Project__c.isAccessible() &&  jiraIssue.id !=Null  && projectSubtaskTypes.containsKey(jiraIssue.Project__c)){
                
                set<String> Subtasks=new Set<String>();
                Subtasks.addAll(new List<String>(projectSubtaskTypes.get(jiraIssue.Project__c).split(',') ));
                
                if(Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isAccessible()  && Subtasks.contains(jiraIssue.IssueType__c)){
                    subtask='true';
                }
            }
            if(subtask=='true' && (projectName=='' || projectName==null)){
                 
                List<JiraIssue__c> parentIssues= new List<JiraIssue__c>();
                if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                    parentIssues=[select id,project__c from JiraIssue__c where IssueKey__c =:Key];
                    if(!parentIssues.isEmpty()){
                        projectName=parentIssues[0].project__c;
                    }
                }
            }
            else if(jiraIssue.id ==Null || (mode.contains('clone') &&  Schema.sObjectType.JiraIssue__c.fields.Project__c.isAccessible() &&  Schema.sObjectType.JiraIssue__c.fields.Project__c.iscreateable())){
                if(jiraIssue.Project__c!=null && mode.contains('clone') && (projectName=='' || projectName==null)){
                    projectName =jiraIssue.Project__c;
                }
                jiraIssue.Project__c= projectName;
                
            }
            else{
                
                if(Schema.sObjectType.JiraIssue__c.fields.Project__c.isAccessible()){
                    projectName  = jiraIssue.Project__c;
                }
                
                ProjectAvailable= jiraProjectskeymap.containsKey(projectName);
                
                
                if(!ProjectAvailable){
                    errorMessage=System.label.TheJiraProject_Label+' ' +jiraIssue.Project__c+ ' '+System.label.Label_ErrorMsg;
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(msg);
                    return; 
                }
                projectIsEditable= creatableProjects.contains(projectName);
            }
            
            if(projectName!='' && projectName!=null){
                 projectSelected=true;
            }
            
            
            //FETCH THE JIRA PROJECT FIELD MAPPING RECORDS
            if(genericObjectName!='' && genericObjectName !=NULL && Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
                
                dynamicFieldsDataMap = new Map<String, Jira_ProjectFieldsMapping__c>();
                dynamicFieldsData = [SELECT Id,Default_Value_long__c,IsStatic__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,
                                     IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  
                                     JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c, Order__c, 
                                     ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Subtask__c,Jira_Project__r.Projectkey__c,  
                                     Jira_Field_Name__c , section__c,Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c,
                                     section__r.name FROM  Jira_ProjectFieldsMapping__c where Jira_Project__r.Projectkey__c=:projectName AND 
                                     Salesforce_Object__c=:genericObjectName order by section__r.order__c,order__c Asc nulls last  limit 1000];
                
            }
            
             DynamicFieldWrapperList =new list<DynamicFieldWrapper>();
             
            
            if(dynamicFieldsData!=NULL && dynamicFieldsData.size()>0){
                
                for(Jira_ProjectFieldsMapping__c field : dynamicFieldsData){
                    //dynamicFieldsDataMap.put(field.JIRA_Field_Api_Name__c, field);
                    if(field.Case_Field_Name__c!=Null && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Case_Field_Name__c.isAccessible()){
                        fields.add(field.Case_Field_Name__c);
                        
                    }
                    if(field.JIRA_Field_Api_Name__c=='issuelinks'){
                        hasIssueLinks =true;
                    }
                    DynamicFieldWrapperList.add(new DynamicFieldWrapper(field,subtask));
                }
            }
            
            fields.remove(null);  
            
            //create the instance of the generic Object  
            if(ConvertType!=NULL){
                
                dynamicObjectType = ConvertType.newSObject(); 
            }
            
           
            string objectfields = '';
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Set<String> objectfield=new set<String>();
            
            if(fields.size()>0 && fields!=NULL){
                
                for(string str :fields){
                    if(genericfieldMap.containsKey(str)){
                        
                        
                        if(genericfieldMap.get(str).tolowercase()=='reference'){
                            String RelName= genericFieldMapTemp.get(str).getDescribe().getRelationshipName();
                            
                            for(Schema.SObjectType  objectName:genericFieldMapTemp.get(str).getDescribe().getReferenceTo()){
                                
                                String Fname='';
                                Map<String, Schema.SObjectField> fieldMap = schemaMap.get(String.valueof(objectName)).getDescribe().fields.getMap();
                                if(fieldMap.containskey('name')){
                                    Fname=RelName+'.name';
                                    
                                    if(!objectfield.contains(Fname))
                                        objectfield.add(Fname);
                                    // objectfields += Fname +',';
                                }else if(String.valueof(objectName).tolowerCase()=='case'){
                                    Fname=RelName+'.CaseNumber';
                                    if(!objectfield.contains(Fname))
                                        objectfield.add(Fname);
                                    //objectfields += Fname +',';
                                }
                            }
                            
                        } 
                        
                        if(str != 'Id' && !objectfield.contains(str)) objectfield.add(str); //+= str +',';
                        
                    }else{
                        if(str != 'Id' && !objectfield.contains(str)) objectfield.add(str); //+= str +',';
                    }
                    
                }
            }
            
            
            List<Sobject> genericSobjectList=new List<Sobject>();
            for(String str:objectfield){
                objectfields+=str+',';
            }
            
            if(genericObjectID !=NULL){
                String query='select '+objectfields+' id From '+ genericObjectName +' where id =:genericObjectID LIMIT 1';
                
                genericSobjectList=Database.Query(query);
                
            }
            
            
            if(genericSobjectList.size()>0 && genericSobjectList!=NULL){
                dynamicObjectType  = genericSobjectList[0];
            }
            
            
            
           
            
            
            
            
            //call function to show the list of jira Project On the page
            projectList();
            
            
            
            //fetch the jira data while viweing the JIRA Issue Record
            CreateJiraData();
            
            //Show the feids on the Edit Add Jira Page; 
            LeftOverDataToLoadPage();
            
            
        }catch(Exception ex){            
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('EditAddJiraIssueController',null, null, null, null,null, null , null, null, 'init', Error));
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            
        }
    }
    
    /*****************************************************************
Fills the jiraProjectsMap with ProjectKey, Jira_Project__c object
******************************************************************/
    public void projectList() {
        
        projects = new List<SelectOption>();
        jiraProjectsMap = new Map<String, Jira_Project__c>();
        
        for(Jira_Project__c projectObject : jiraProjectsList){
            jiraProjectsMap.put(projectObject.ProjectKey__c, projectObject);
            
            if(projectObject.write__c)
                projects.add(new SelectOption(projectObject.ProjectKey__c, projectObject.name));
        }
        
        
    }
    
    public void CreateJiraData(){

        if(jiraIssue!=Null && jiraIssue.JsonData__c!=Null && tasktype!='true'){
            
            Map<String, Object> JsonData = (Map<String, Object>) JSON.deserializeUntyped(jiraIssue.JsonData__c);
            
            oldIssueType=jiraIssue.IssueType__c;
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
                        }else if((FieldType.toLowerCase()=='version' && !dynamic.mappedField.IsArray__c)||FieldType.toLowerCase()=='select'||FieldType.toLowerCase()=='radiobuttons'){
                            value=value.removeEnd(',');
                            dynamic.fieldValue=value;
                        }else if( FieldType.toLowerCase()=='userpicker'||
                                 FieldType.toLowerCase()=='user'  ){
                                     map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
                                     
                                     if(JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c)!=null){
                                         Map<String,Object> MapofUserdetail = (Map<String,Object>)JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c);
                                         if(MapofUserdetail.get('name')==NULL || MapofUserdetail.get('name')==''){
                                             HttpResponse res = new HttpResponse();
                                             Http http = new Http();
                                             HttpRequest req = new HttpRequest();
                                             req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/picker?query='+EncodingUtil.urlEncode((String)MapofUserdetail.get('displayName'), 'UTF-8'), 'GET', 'application/json');
                                             
                                             res = http.send(req);
                                             String jsonInput;
                                             jsonInput = res.getBody(); 
                                             
                                             if(res.getStatusCode()==200){
                                                 Map<String, Object> UserResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                                                 List<Object>userlist = (List<Object>)UserResponseMap.get('users');
                                                 for(Object user:userlist){
                                                     Map<String, Object> UserMap = (Map<String, Object>)User;
                                                     
                                                     if(String.valueOf(UserMap.get('accountId'))==String.valueOf(MapofUserdetail.get('accountId'))){
                                                         UserMap.remove('html');
                                                         dynamic.username=String.valueOf(UserMap.get('displayName'));
                                                         if(UserMap.get('name')!=null && String.valueof(UserMap.get('name'))!=''){
                                                             dynamic.username  +=' ('+ String.valueOf(UserMap.get('name'))+')';
                                                         }  
                                                         dynamic.usermapFinal.put(dynamic.username,Json.serialize(UserMap) );
                                                         break;
                                                     }
                                                 }
                                                 
                                             }else{
                                                 JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'CreateJiraData(userpicker)', res.getbody()));   
                                             }
                                             
                                         }
                                         else{
                                            
                                             dynamic.username=String.valueOf(MapofUserdetail.get('displayName'));
                                             if(MapofUserdetail.get('name')!=null && String.valueof(MapofUserdetail.get('name'))!=''){
                                                 dynamic.username  +=' ('+ String.valueOf(MapofUserdetail.get('name'))+')';
                                             }  
                                             dynamic.usermapFinal.put(dynamic.username,Json.serialize(MapofUserdetail) );
                                         }  
                                     }
                                     dynamic.fieldValue=value;
                                     if(dynamic.mappedField.jira_field_api_name__c=='assignee' && (value ==null ||value=='')){
                                         dynamic.fieldValue='Unassigned';
                                     }else{
                                         value=value.removeEnd(',');
                                         dynamic.fieldValue=value; 
                                     }
                                 }else if(FieldType.toLowerCase()=='multiuserpicker'){
                                     
                                     map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
                                     dynamic.fieldValue='';
                                     if(JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c)!=null){
                                         List<Object> ListOFuserObject=(List<Object>) JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c);
                                         for(Object UserObj:ListOFuserObject){
                                             Map<String,Object> MapofUserdetail  = (Map<String,Object>)UserObj;
                                           
                                             if(MapofUserdetail.get('name')==NULL || MapofUserdetail.get('name')==''){
                                                 HttpResponse res = new HttpResponse();
                                                 Http http = new Http();
                                                 HttpRequest req = new HttpRequest();
                                                 req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/picker?query='+EncodingUtil.urlEncode((String)MapofUserdetail.get('displayName'), 'UTF-8'), 'GET', 'application/json');
                                                 res = http.send(req);
                                                 String jsonInput;
                                                 jsonInput = res.getBody(); 
                                                 
                                                 if(res.getStatusCode()==200){
                                                     Map<String, Object> UserResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                                                     List<Object>userlist = (List<Object>)UserResponseMap.get('users');
                                                     
                                                     for(Object user:userlist){
                                                         Map<String, Object> UserMap = (Map<String, Object>)User;
                                                         if(String.valueOf(UserMap.get('accountId'))==String.valueOf(MapofUserdetail.get('accountId'))){
                                                             
                                                             String Mapkey=String.valueOf(UserMap.get('displayName'));
                                                             if(UserMap.get('name')!=null && String.valueof(UserMap.get('name'))!=''){
                                                                 Mapkey  +=' ('+ String.valueOf(UserMap.get('name'))+')';
                                                             }  
                                                             dynamic.usermapFinal.put(Mapkey,Json.serialize(UserMap));
                                                             dynamic.fieldValue=dynamic.fieldValue==''?(String)UserMap.get('displayName'):(dynamic.fieldValue+', '+(String)UserMap.get('displayName'));
                                                                 break;
                                                         }
                                                     }
                                                     
                                                 }else{
                                                     JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'CreateJiraData(multiuserpicker)', res.getbody()));   
                                                 }
                                                 
                                             }else{
                                                 
                                                 String Mapkey=String.valueOf(MapofUserdetail.get('displayName'));
                                                 if(MapofUserdetail.get('name')!=null && String.valueof(MapofUserdetail.get('name'))!=''){
                                                     Mapkey  +=' ('+ String.valueOf(MapofUserdetail.get('name'))+')';
                                                 }  
                                                 dynamic.usermapFinal.put(Mapkey,Json.serialize(MapofUserdetail));
                                                 dynamic.fieldValue=dynamic.fieldValue==''?(String)MapofUserdetail.get('displayName'):(dynamic.fieldValue+', '+(String)MapofUserdetail.get('displayName'));
                                                     }  
                                             
                                         }
                                     } 
                                 }else if(FieldType.toLowerCase()=='multiversion'||FieldType.toLowerCase()=='multiselect'||FieldType.toLowerCase()=='multicheckboxes'||FieldType.toLowerCase()=='version'||FieldType.toLowerCase()=='component'){
                                     
                                     list<String> ValueList= Value.split(',');
                                    
                                     Value='';
                                     for(String Temp: ValueList){
                                         for(String Selectvalue:dynamic.selectValueMap.keyset()){
                                             if(Temp==(dynamic.selectValueMap.get(Selectvalue).toLowerCase())){
                                                 dynamic.multiselectvalues.add(Selectvalue);
                                                 
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
                                     if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible() && issueLinkField.JIRA_Field_Api_Name__c != null){
                                         req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+issue_Key+'?fields='+issueLinkField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                         res =http.send(req); 
                                         if(res.getstatuscode()==200){
                                             Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                             IssuelinksMap = FieldJsonHelper.getIssueLinkData(issueLinkField.JIRA_Field_Api_Name__c,EpicJsonData);
                                             dynamic.fieldValue= null;
                                             SizeOfMapLI = IssuelinksMap.size();
                                         }else{
                                             JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'CreateJiraData(issuelinks)', res.getbody()));   
                                         }
                                     }
                                 }
                        
                    }else{
                        
                        if(FieldType.toLowerCase()=='gh-epic-label'||FieldType.toLowerCase()=='gh-epic-link'||FieldType.toLowerCase()=='float'||FieldType.toLowerCase()=='textfield'||FieldType.toLowerCase()=='string'||FieldType.toLowerCase()=='textarea'||FieldType.toLowerCase()=='issuelink'){
                            if(dynamic.mappedField.Jira_Field_api_Name__c.toLowerCase()=='resolutiondate'){
                                
                                dynamic.fieldValue=EditAddJiraIssueController.ConvertDate(value);
                                
                            }
                            else if(FieldType.toLowerCase()=='issuelink' ){
                                
                                
                                HttpRequest req = new HttpRequest(); 
                                Http http = new Http();
                                HTTPResponse res;
                                
                                if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible() && jiraIssuelInkField.JIRA_Field_Api_Name__c != null){
                                    
                                    req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+Value+'?fields='+jiraIssuelInkField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                    
                                    res =http.send(req); 
                                    if(res.getstatuscode()==200){
                                        Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        parents = FieldJsonHelper.getFieldData('key',EpicJsonData);
                                        
                                        dynamic.fieldValue= parents;
                                        List<JiraIssue__c> parentIssueId= new List<JiraIssue__c>();
                                        if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                                            parentIssueId=[select id from JiraIssue__c where IssueKey__c =:parents];
                                        }
                                        if(Schema.sObjectType.JiraIssue__c.fields.id.isAccessible() && parentIssueId.size()>0 && parentIssueId!=NULL){
                                            subtaskParentID=parentIssueId[0].id;
                                        }
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'CreateJiraData(issuelink)', res.getbody()));   
                                    }
                                }
                            }
                            else {
                                dynamic.fieldValue=Value; 
                                
                            }
                            if(FieldType.toLowerCase()=='gh-epic-link'){
                                HttpRequest req = new HttpRequest(); 
                                
                                Http http = new Http();
                                HTTPResponse res;
                                if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible() && jiraField.JIRA_Field_Api_Name__c != null){
                                    
                                    req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+Value+'?fields='+jiraField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                    res =http.send(req); 
                                    if(res.getstatuscode()==200){
                                        Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        epicKey = FieldJsonHelper.getFieldData(jiraField.JIRA_Field_Api_Name__c,EpicJsonData);
                                        
                                        dynamic.fieldValue= Value;
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, null, 'CreateJiraData(gh-epic-link)', res.getbody()));   
                                    }
                                }
                            }                                    
                        }else if(FieldType.toLowerCase()=='datepicker'){
                            dynamic.datevalue= value;
                            
                        }else if(FieldType.toLowerCase()=='datetime'){
                            
                            String dtval=value.replace('T',' ');
                            Datetime dt=DateTime.valueof(dtval);
                            String dtValue=String.valueof(dt.format('yyyy-MM-dd\'T\'hh:mm'));
                            dynamic.datetimevalue= dtValue;
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
            if(jiraIssue.id==Null){
                
                //  --------------------------------------
                if(Dfield.mappedField.Case_Field_Name__c!=Null && 
                   dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c)!=NULL){
                       //SobjectField
                       //
                       //dateTime
                       //
                      
                       if(Dfield.mappedField.DataType__c=='dateTime'){
                           Datetime dt=DateTime.valueOf(dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c));
                           Dfield.datetimevalue=String.valueof(dt.format('yyyy-MM-dd\'T\'hh:mm'));
                       }
                       else if(Dfield.mappedField.DataType__c=='datepicker'){
                           Datetime dt=Date.valueof(dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c));
                           Dfield.datevalue=string.valueof(dt.formatGMT('yyyy-MM-dd'));
                       }
                       else if(Dfield.mappedField.IsArray__c &&
                               (Dfield.mappedField.DataType__c.toLowerCase()=='multiversion'||
                                Dfield.mappedField.DataType__c.toLowerCase()=='multiselect'||
                                Dfield.mappedField.DataType__c.toLowerCase()=='multicheckboxes'||
                                Dfield.mappedField.DataType__c.toLowerCase()=='version'||
                                Dfield.mappedField.DataType__c.toLowerCase()=='component')){
                                    String Value =String.valueof(dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c));
                                    list<String> ValueList= Value.split(';');
                                    Value='';
                                    for(String Temp: ValueList){
                                        for(String Selectvalue:Dfield.selectValueMap.keyset()){
                                            if(Temp==Selectvalue.toLowerCase()){
                                                Dfield.multiselectvalues.add(Selectvalue); 
                                            }
                                        }
                                    }                          
                                    
                                }
                       else if((Dfield.mappedField.DataType__c.toLowerCase()=='version' && !Dfield.mappedField.IsArray__c)||
                               Dfield.mappedField.DataType__c.toLowerCase()=='select'||
                               Dfield.mappedField.DataType__c.toLowerCase()=='radiobuttons'){
                                   String Value =String.valueof(dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c));
                                   
                                   value=value.removeEnd(',');
                                   Dfield.fieldValue=value;
                               }
                       else if(Dfield.mappedField.DataType__c=='user' || Dfield.mappedField.DataType__c=='userpicker' ||
                               Dfield.mappedField.DataType__c=='multiuserpicker'){
                                   String UserEmails= String.valueof(dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c));
                                   for(String userEmail:UserEmails.split(',')){
                                       if(userEmail== null || userEmail.trim()==''){
                                           continue;
                                       }
                                       HttpResponse res = new HttpResponse();
                                       Http http = new Http();
                                       HttpRequest req = new HttpRequest();
                                       
                                       req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/picker?query='+EncodingUtil.urlEncode(userEmail,'UTF-8'), 'GET', 'application/json');
                                       res = http.send(req);
                                       String jsonInput;
                                       jsonInput = res.getBody();   
                                       if(res.getStatusCode()==200 || test.isRunningTest()){
                                           if(test.isRunningTest()){
                                               jsonInput='{"users":[{"accountId":"5c82215b3ae6c605e332b11c","accountType":"atlassian","name":"95d4e080-1db1-44db-97c6-87307a5bc870","key":"95d4e080-1db1-44db-97c6-87307a5bc870","html":"Zylo <strong>Integration</strong> - zylo_integration@yext.com","displayName":"Zylo Integration"}],"total":2,"header":"Showing 2 of 2 matching users"}';
                                           }
                                           Map<String, Object> UserResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                                           List<Object>userlist = (List<Object>)UserResponseMap.get('users');
                                           for(Object user:userlist){
                                               Map<String, Object> UserMap = (Map<String, Object>)User;
                                               if(UserMap.get('displayName')!=null){
                                                   String selectval=String.valueOf(UserMap.get('displayName'));
                                                   if(UserMap.get('name')!=null && String.valueof(UserMap.get('name'))!=''){
                                                       selectval  +=' ('+ String.valueOf(UserMap.get('name'))+')';
                                                   }  
                                                   UserMap.remove('html');
                                                   String MapVal=Json.serialize(UserMap);
                                                   Dfield.usermapFinal.put(selectval,MapVal);
                                                   if( Dfield.mappedField.DataType__c!='multiuserpicker'){
                                                       Dfield.username=selectval;
                                                       Dfield.fieldValue=selectval;
                                                   }
                                               }
                                           }
                                       }else{
                                           JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'LeftOverDataToLoadPage(userpicker)', res.getbody()));   
                                       }
                                   }
                               }
                       else if(Dfield.mappedField.DataType__c!='user' && Dfield.mappedField.DataType__c!='userpicker'&&
                               Dfield.mappedField.DataType__c!='multiuserpicker'){
                                   Dfield.fieldValue= String.valueof(dynamicObjectType.get(Dfield.mappedField.Case_Field_Name__c));
                               } 
                   }   
                else if(Dfield.mappedField.Case_Field_Name__c==Null &&
                        Dfield.mappedField.Default_Value_long__c!=NULL){
                            //defaultvalue
                            //
                            //dateTime
                            if(Dfield.mappedField.DataType__c=='dateTime'){
                                Datetime dt=DateTime.valueOf(Dfield.mappedField.Default_Value_long__c.replace('T',' '));
                                Dfield.datetimevalue=String.valueof(dt.format('yyyy-MM-dd\'T\'hh:mm'));     
                            }
                            //datepicker
                            else if(Dfield.mappedField.DataType__c=='datepicker'){
                                Datetime dt=Date.valueof(Dfield.mappedField.Default_Value_long__c);
                                Dfield.datevalue=string.valueof(dt.formatGMT('yyyy-MM-dd'));
                            }
                            else if(Dfield.mappedField.IsArray__c || Dfield.mappedField.DataType__c=='version'){
                                String FieldType=Dfield.mappedField.DataType__c;
                                String value=Dfield.mappedField.Default_Value_long__c; 
                                
                                //cascadingselect
                                if(FieldType.toLowerCase()=='cascadingselect'){
                                    Dfield.masterFieldValue=Dfield.clubMasterMapRev.get(value);
                                    if(value.contains('_child_')){
                                        list<String> DepValue=value.split('_child_');
                                        Dfield.childFieldValue=DepValue[1]; 
                                        Dfield.masterFieldValue=DepValue[0];
                                    }
                                }
                                //labels textfield textarea string
                                else if(FieldType.toLowerCase()=='labels'||
                                        FieldType.toLowerCase()=='string' ||
                                        FieldType.toLowerCase()=='textarea'||
                                        FieldType.toLowerCase()=='textfield'){
                                            value=value.replace(',',' ');
                                            Dfield.fieldValue=value;
                                        }
                                //version-nonarray, select, radiobutton
                                // pending user, userpicker,multiuserpicker
                                else if((FieldType.toLowerCase()=='version' && !Dfield.mappedField.IsArray__c)||
                                        FieldType.toLowerCase()=='select'||
                                        FieldType.toLowerCase()=='radiobuttons'){
                                            value=value.removeEnd(',');
                                            Dfield.fieldValue=value;
                                        }
                                
                                else if(Dfield.mappedField.IsArray__c &&
                                        (FieldType.toLowerCase()=='multiversion'||
                                         FieldType.toLowerCase()=='multiselect'||
                                         FieldType.toLowerCase()=='multicheckboxes'||
                                         FieldType.toLowerCase()=='version'||
                                         FieldType.toLowerCase()=='component')){
                                             list<String> ValueList= Value.split(',');
                                             Value='';
                                             for(String Temp: ValueList){
                                                 for(String Selectvalue:Dfield.selectValueMap.keyset()){
                                                     if(Temp==Selectvalue.toLowerCase()){
                                                         Dfield.multiselectvalues.add(Selectvalue); 
                                                     }
                                                 }
                                             }                          
                                             
                                         }
                                else if(Dfield.mappedField.DataType__c=='user' || Dfield.mappedField.DataType__c=='userpicker'){
                                    Map<String,Object>UserMap = (Map<String,Object>)JSON.deserializeUntyped(Dfield.mappedfield.Default_Value_long__c);
                                    Dfield.username=String.valueOf(UserMap.get('displayName'));
                                    if(UserMap.get('name')!=null && String.valueof(UserMap.get('name'))!=''){
                                        Dfield.username  +=' ('+ String.valueOf(UserMap.get('name'))+')';
                                    }  
                                    Dfield.UserMapFinal.put(Dfield.username,Dfield.mappedfield.Default_Value_long__c);
                                } 
                                else if(Dfield.mappedfield.datatype__c=='multiuserpicker'){
                                    Dfield.fieldValue=''; 
                                    Dfield.username='';
                                    Map<String,Object>UsersMap = (Map<String,Object>)JSON.deserializeUntyped(Dfield.mappedfield.Default_Value_long__c);
                                    List<Object>Users = (List<Object>)UsersMap.get('users');
                                    for(Object us:Users){ 
                                        Map<String,Object>UserMap = (Map<String,Object>)us;
                                        String selectval=String.valueOf(UserMap.get('displayName'));
                                        if(UserMap.get('name')!=null && String.valueof(UserMap.get('name'))!=''){
                                            selectval  +=' ('+ String.valueOf(UserMap.get('name'))+')';
                                        } 
                                        
                                        Dfield.UserMapFinal.put(selectval,JSON.serialize(us));
                                    }
                                }
                            }
                            
                            else {
                                Dfield.fieldValue=Dfield.mappedField.Default_Value_long__c;
                            } 
                        }
                
                
                if(Dfield.mappedField.DataType__c=='issuelink' && tasktype=='true'){
                    
                    List<JiraIssue__c> parentIssueId= new List<JiraIssue__c>();
                    if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                        parentIssueId=[select id,project__c from JiraIssue__c where IssueKey__c =:Key];
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.id.isAccessible() && parentIssueId!=NULL && parentIssueId.size()>0){
                        subtaskParentID=parentIssueId[0].id;
                    }
                    Dfield.fieldValue=key;
                    
                }
            }
            
            if(sectionToDynamicFieldWrapperListMap.containsKey(Dfield.mappedField.Section__r.Name)){
                Map<Integer,Map<String,DynamicFieldWrapper>> InnerMap =sectionToDynamicFieldWrapperListMap.get(Dfield.mappedField.Section__r.Name);
                if( InnerMap.containskey(Integer.valueof(Dfield.mappedField.Order__c))){
                    InnerMap.get(Integer.valueof(Dfield.mappedField.Order__c)).put(Dfield.mappedField.JIRA_Field_Api_Name__c,Dfield);
                }else{
                    InnerMap.put(Integer.valueOf(Dfield.mappedField.Order__c),new Map<String,DynamicFieldWrapper>{Dfield.mappedField.JIRA_Field_Api_Name__c=>Dfield});
                }
                
                sectionToDynamicFieldWrapperListMap.put(Dfield.mappedField.Section__r.Name,InnerMap);
                
            }else{
                Map<Integer,Map<String,DynamicFieldWrapper>> InnerMap = new Map<Integer,Map<String,DynamicFieldWrapper>>();
                InnerMap.put(Integer.valueOf(Dfield.mappedField.Order__c),new Map<String,DynamicFieldWrapper>{Dfield.mappedField.JIRA_Field_Api_Name__c=>Dfield});
                
                sectionToDynamicFieldWrapperListMap.put(Dfield.mappedField.Section__r.Name,InnerMap);
                SectionOrder.add(Dfield.mappedField.Section__r.Name);
                
            }
            
            if(Dfield.mappedField.name=='Issue Type' && Dfield.mappedField.Jira_Project__r.Projectkey__c==projectname  ){
                
                if(!Dfield.selectValues.isEmpty() && jiraIssue !=null && jiraIssue.IssueType__c ==null){
                    
                    for(SelectOption key: Dfield.selectValues){
                        String defaultIssueType = ProjectkeyToObjectmap.get(projectname).DefaultIssueType__c;
                        if (defaultIssueType != null  && tasktype!='true') {
                            jiraIssue.IssueType__c = defaultIssueType;
                            
                        } else {
                            
                            
                            jiraIssue.IssueType__c=key.getvalue();
                            break;
                        }
                    }
                }
            }
            
            /* if(Dfield.mappedField.name=='Reporter' && jiraIssue.id==null && tasktype!='true' && Dfield.mappedField.Default_Value__c==NULL){
if(!Dfield.selectValues.isEmpty() ){
Dfield.fieldValue = setting.displayname__c;
}
}*/
            
            if(Dfield.mappedField.name=='Reporter' && Dfield.mappedField.JIRA_Field_Api_Name__c=='reporter' && jiraIssue.id==Null){
                String SearchUserBy;
                if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
                    SearchUserBy = JiraSalesforceDetail__c.getValues('Reporter_User_Email')!=null? JiraSalesforceDetail__c.getValues('Reporter_User_Email').Value__c!=null? JiraSalesforceDetail__c.getValues('Reporter_User_Email').Value__c:'':'';
                }
                if(SearchUserBy.toLowerCase()=='email' && SearchUserBy!=''){
                    SearchUserBy = userinfo.getUserEmail();
                }else if(SearchUserBy.toLowerCase()=='username' && SearchUserBy!=''){
                    SearchUserBy =userinfo.getusername(); 
                }
                if(SearchUserBy!='' && SearchUserBy!=null){
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/picker?query='+EncodingUtil.urlEncode(SearchUserBy, 'UTF-8'), 'GET', 'application/json');
                    res = http.send(req);
                    String jsonInput;
                    jsonInput = res.getBody();   
                    if(res.getStatusCode()==200 || test.isRunningTest()){
                        if(test.isRunningTest()){
                            jsonInput='{"users":[{"accountId":"5c82215b3ae6c605e332b11c","accountType":"atlassian","name":"95d4e080-1db1-44db-97c6-87307a5bc870","key":"95d4e080-1db1-44db-97c6-87307a5bc870","html":"Zylo <strong>Integration</strong> - zylo_integration@yext.com","displayName":"Zylo Integration"}],"total":2,"header":"Showing 2 of 2 matching users"}';
                        }
                        Map<String, Object> UserResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                        List<Object>userlist = (List<Object>)UserResponseMap.get('users');
                        for(Object user:userlist){
                            Map<String, Object> UserMap = (Map<String, Object>)User;
                            if(UserMap.get('displayName')!=null){
                                String selectval=String.valueOf(UserMap.get('displayName'))+' ('+String.valueOf(UserMap.get('name'))+')';
                                UserMap.remove('html');
                                String MapVal=Json.serialize(UserMap);
                                Dfield.usermapFinal.put(selectval,MapVal);
                                Dfield.username=selectval;
                                Dfield.fieldValue=selectval;
                                
                            }
                        }
                    }else{
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Adminsettingcontroller',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'LeftOverDataToLoadPage(reporter)', res.getbody()));   
                    }
                }
            }
        }
        if(sectionToDynamicFieldWrapperListMap.isEmpty()){
            mapNotEmpty=false;
        }else{
            mapNotEmpty=true;
        }
        
    }
    
    
    /**************************************************************
This Fucntion is Called When Jira Project is Changed on the Page
****************************************************************/
    public PageReference OnProjectChange(){
        if(projectName!=null && projectName!='None'){
            
            projectSelected=true;
            init();
        }else{ projectSelected=false;}
        return null;
        
    } 
    
    public PageReference save(){ 
        String EndPoint='';
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            EndPoint = Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA').End_Point__c!= null ? Jira_login__c.getValues('JIRA').End_Point__c+'/browse/' : '' : '';
        }
        errorMessage='';
        String dynamicData = '';
        String TempValue= '';
        String IssyeTypeJsonData='';
        Set<String> IssueLinkType = new Set<String>();
        fieldsToKey = new Map<String,String>();
        SizeOfMapLI=0;
        SizeOfMap=0;
        if(!DynamicFieldWrapperList.isEmpty() && DynamicFieldWrapperList!=null){
            
            for(DynamicFieldWrapper dynamic: DynamicFieldWrapperList){                
                
                
                if(dynamic.mappedField.jira_project__c == jiraProjectskeymap.get(projectName) && 
                   dynamic.mappedField.viewmode__c!=true &&
                   dynamic.mappedField.IssueTypeData__c!=null &&
                   (dynamic.mappedField.IssueTypeData__c.contains('--'+jiraIssue.IssueType__c+'--') ||
                    dynamic.mappedField.IssueTypeData__c=='All')){                        

                        if(dynamic.mappedField.IsArray__c ||dynamic.mappedField.DataType__c=='version'){
                            
                            if(dynamic.mappedField.DataType__c.toLowerCase()=='cascadingselect' && dynamic.mappedField.ProjectissueTypeData__c!=NULL){
                                TempValue=null;
                                if(dynamic.masterFieldValue!='None' && dynamic.masterFieldValue!=null && dynamic.masterFieldValue!=''){
                                    TempValue='{"id":"'+dynamic.masterFieldValue+'"';
                                    if( dynamic.childFieldValue!='None' && dynamic.childFieldValue!=null && dynamic.childFieldValue!=''){
                                        TempValue+=',"child":{"id":"'+ dynamic.childFieldValue+'"}';
                                    }
                                    TempValue+= '}';
                                }
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+TempValue;
                            }
                            else if(dynamic.mappedField.DataType__c.toLowerCase()=='string'||dynamic.mappedField.DataType__c.toLowerCase()=='labels'){
                                TempValue= '';
                                
                                if(dynamic.fieldValue!=null){
                                    list<string> SelectedValue= dynamic.fieldValue.split(' ');
                                    for(String value:SelectedValue){
                                        TempValue+='"'+value+'",';
                                    }
                                    TempValue=TempValue.removeEnd(',');
                                }
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+'['+TempValue+']';
                            }
                            else if(((!dynamic.mappedField.IsArray__c && dynamic.mappedField.DataType__c.toLowerCase()=='version')||dynamic.mappedField.DataType__c.toLowerCase()=='select'||dynamic.mappedField.DataType__c.toLowerCase()=='radiobuttons'||dynamic.mappedField.DataType__c.toLowerCase()=='issuelinks') && dynamic.mappedField.ProjectissueTypeData__c!=NULL){
                                TempValue=null;
                                if(Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isAccessible() && dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='issuetype'){
                                    dynamic.fieldValue=jiraIssue.IssueType__c;
                                }
                                else if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='priority'){
                                    jiraIssue.Priority__c=dynamic.fieldValue; 
                                }
                                if(dynamic.fieldValue!=Null){
                                    String value=dynamic.fieldValue;
                                    for(String key:dynamic.selectValueMap.keySet()){
                                        if(key.toLowerCase().equals(value.toLowerCase())){
                                            if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='issuelinks'){
                                                // IssueLinkType=key;
                                            }else{
                                                TempValue='{"id":"'+ dynamic.selectValueMap.get(key) + '","value":"'+key.escapeJava()+'"}';
                                            }
                                        }                                            
                                    }
                                    for(String Key1:IssuelinksMapValue.Keyset()){
                                        IssueLinkType.add(key1);
                                    } 
                                }else{ 
                                    TempValue=null; 
                                }
                                
                                if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='issuelinks' && 
                                   (!issuelinksset.isEmpty()) && (IssueLinkType.isEmpty())){
                                       //errorMessage+='You must specify the '+ dynamic.mappedField.name+'Type.<br/> ';
                                       errorMessage+= System.label.EditAddjiraIssuecontroller_Label3+' ' +dynamic.mappedField.name+ System.label.EditAddjiraIssuecontroller_Label4 +'.<br/>' ;
                                   }
                                
                                if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()!='issuelinks')
                                    dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+TempValue;
                                
                                if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='issuetype'){
                                    IssyeTypeJsonData=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+TempValue;
                                }
                            }
                            else if(dynamic.mappedField.DataType__c.toLowerCase()=='userpicker'||dynamic.mappedField.DataType__c.toLowerCase()=='user'){
                                TempValue='';
                                //modified on 01-07-2019
                                if(dynamic.username!=Null && dynamic.UserMapFinal.get(dynamic.username)!=null){
                                    if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='assignee'){
                                        jiraIssue.Assignee__c=dynamic.username; 
                                    } 
                                    TempValue= dynamic.UserMapFinal.get(dynamic.username);
                                }else{ 
                                    TempValue=null; 
                                }
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+TempValue;
                            }
                            else if(dynamic.mappedField.DataType__c.toLowerCase()=='multiuserpicker'){
                                TempValue='';
                                for(String Userkey:dynamic.UserMapFinal.keySet()){
                                    TempValue+=dynamic.UserMapFinal.get(Userkey)+',';                                    
                                }
                                TempValue=TempValue.removeEnd(',');
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+'['+TempValue+']';
                            }
                            else if(dynamic.mappedField.ProjectissueTypeData__c!=NULL && dynamic.mappedField.IsArray__c &&(dynamic.mappedField.DataType__c.toLowerCase()=='multiversion' ||
                                                                      dynamic.mappedField.DataType__c.toLowerCase()=='multiselect' ||
                                                                      dynamic.mappedField.DataType__c.toLowerCase()=='multicheckboxes'||
                                                                      dynamic.mappedField.DataType__c.toLowerCase()=='version' ||
                                                                      dynamic.mappedField.DataType__c.toLowerCase()=='component') ){
                                TempValue= '';
                                if(dynamic.multiselectvalues!=NULL && !dynamic.multiselectvalues.isEmpty()){
                                    for(String value:dynamic.multiselectvalues){
                                        value=value.trim();
                                        for(String key:dynamic.selectValueMap.keySet()){
                                            if(key.toLowerCase().equals(value.toLowerCase())){
                                                TempValue+='{"id":"'+ dynamic.selectValueMap.get(key) + '","value":"'+key+'"},';  
                                            }
                                        }
                                    }
                                    TempValue=TempValue.removeEnd(',');
                                }
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+'['+TempValue+']';
                            }                   
                        }
                        else{
                            if(dynamic.mappedField.DataType__c.toLowerCase()=='float'||dynamic.mappedField.DataType__c.toLowerCase()=='double'||dynamic.mappedField.DataType__c.toLowerCase()=='integer'||dynamic.mappedField.DataType__c.toLowerCase()=='decimal'||dynamic.mappedField.DataType__c.toLowerCase()=='long'){
                                TempValue='';
                                String value=dynamic.fieldValue;
                                TempValue=value;
                                if(value==null||value=='') TempValue=null;
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+TempValue;
                            }else if(dynamic.mappedField.DataType__c.toLowerCase()=='url'||
                                     dynamic.mappedField.DataType__c.toLowerCase()=='textfield'||
                                     dynamic.mappedField.DataType__c.toLowerCase()=='textarea'||
                                     dynamic.mappedField.DataType__c.toLowerCase()=='string'||
                                     dynamic.mappedField.DataType__c.toLowerCase()=='datepicker'||
                                     dynamic.mappedField.DataType__c.toLowerCase()=='datetime'||
                                     dynamic.mappedField.DataType__c.toLowerCase()=='gh-epic-label'||
                                     (dynamic.mappedField.DataType__c.toLowerCase()=='gh-epic-link' && subtask!='true') || 
                                     dynamic.mappedField.DataType__c.toLowerCase()=='issuelink'){
                                TempValue='';
                                String value='';
                                if(dynamic.mappedField.DataType__c.toLowerCase()=='datetime' && Dynamic.datetimevalue!=NULL && Dynamic.datetimevalue!=''){
                                    String inputDt=Dynamic.datetimevalue;
                                    inputDt = inputDt.replace('T', ' ');
                                    inputDt += ':00';
                                    DateTime dt=DateTime.valueOf(inputDt);
                                    value=String.valueOf(dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
                                    value=value.substring(0,value.lastIndexOf('-'))+'-0000';
                                    TempValue='"'+ value + '"';
                                }
                                else if(dynamic.mappedField.DataType__c.toLowerCase()=='datepicker' && Dynamic.datevalue!=NULL && Dynamic.datevalue!=''){
                                    value=Dynamic.datevalue;
                                    TempValue='"'+ value + '"';
                                }
                                else if(dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()=='parent'){
                                    TempValue='{"key":'+'"'+ dynamic.fieldValue + '"}';
                                }
                                else if(dynamic.fieldValue!=Null && dynamic.fieldValue!=''){
                                    value=  dynamic.fieldValue;   
                                    value=value.escapeJava();
                                    TempValue='"'+ value + '"';
                                }
                                else{
                                    value=Null; 
                                    TempValue=Null;
                                }
                                dynamicData+=',"'+dynamic.mappedField.JIRA_Field_Api_Name__c +'":'+TempValue;
                            }
                        }                            
                        
                        
                        
                        //-------Required Check--------------
                      
                        if(((dynamic.mappedField.ReqInIssueTypeData__c!=null && dynamic.relatedReqIssue.contains('--'+jiraIssue.IssueType__c+'--')) ||
                            dynamic.mappedField.RequiredInSF__c) 
                           && (TempValue==Null || TempValue=='') && dynamic.mappedField.JIRA_Field_Api_Name__c.toLowerCase()!='issuelinks'
                          && dynamic.mappedField.datatype__c=='gh-epic-link'){
                               
                               errorMessage+= System.label.EditAddjiraIssuecontroller_Label2+' ' +dynamic.mappedField.name+'.<br/>';
                           }
                         
                        
                    }                
            }
            
        }
        
        if(String.isNotEmpty(errorMessage)){
            
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(msg);
            return null; 
        }
        try{
            
            // mode='';
            if(mode.contains('clone')){
                
                jiraIssue.id=null; 
                //if(casenumber!=null && (caseNumberApi ==''||caseNumberApi ==null ))jiraIssue.CaseNos__c=casenumber;
                
            }
            if(tasktype == 'true'){
                jiraIssue.CaseNos__c=null;
            }
            
            String body='';
            
            if(jiraIssue.id==null || oldIssueType == jiraIssue.IssueType__c ){
                
                body = '{"fields":{"project":{"key":"'+projectName+'"}'+
                    (String.isNotEmpty(dynamicData)==true?dynamicData:'')+/*Code for dynamic data*/     
                    '}}';
                if(oldIssueType == jiraIssue.IssueType__c && jiraIssue.id!=null){
                    body = '{"key":"'+jiraIssue.IssueKey__c+'","fields":{"project":{"key":"'+projectName+'"}'+
                        (String.isNotEmpty(dynamicData)==true?dynamicData:'')+/*Code for dynamic data*/     
                        '}}';
                }
                
            }else{
                
                body='{"key":"'+jiraIssue.IssueKey__c+'","fields":{"project":{"key":"'+projectName+'"}'+IssyeTypeJsonData + '}}';
                HttpRequest req = new HttpRequest(); 
                
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue'+ ((String.isNotEmpty(jiraIssue.Id))?('/'+jiraIssue.IssueKey__c):'') ,((String.isEmpty(jiraIssue.Id))?'POST':'PUT') ,'application/json');
                req.setBody(body);    
                
                Http http = new Http();
                HTTPResponse res;
                try {
                    res = http.send(req);
                    
                    if(res.getStatusCode()==204 || res.getStatusCode()==201){
                        body = '{"fields":{"project":{"key":"'+projectName+'"}'+
                            (String.isNotEmpty(dynamicData)==true?dynamicData:'')+/*Code for dynamic data*/     
                            '}}'; 
                    }else{
                        GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Save Issue', res.getBody());
                    }
                    
                } catch(System.CalloutException e){ 
                    
                    errorMessage = e.getMessage();
                    
                    GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Save Issue', Errormessage);
                } catch(Exception ex){
                    
                    String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, null, 'Save Issue', Errormessage);
                }
            } 
            
            HttpRequest req = new HttpRequest(); 
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue'+ ((String.isNotEmpty(jiraIssue.Id))?('/'+jiraIssue.IssueKey__c):'') ,((String.isEmpty(jiraIssue.Id))?'POST':'PUT') ,'application/json');
            req.setBody(body); 
            Http http = new Http();
            HTTPResponse res;
            try {
                res = http.send(req);
                
                if(res.getStatusCode()==204 || res.getStatusCode()==201 ){
                    if(IssueLinkType!=null){
                        
                        String currentKey='';
                        if(res.getStatusCode()==201){
                            Map<String,Object> getresponseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                            currentKey= (String)getresponseMap.get('key');
                        }else if(res.getStatusCode()==204){
                            currentKey = jiraIssue.IssueKey__c; 
                            
                        }
                        String LinkedIssuesBody = '';
                        if(!issuelinksset.isEmpty()){
                            
                            for(String LinkLabels:IssuelinksMapValue.KeySet()){
                                
                                For(String linkKeys : IssuelinksMapValue.get(LinkLabels)){
                                    
                                    LinkedIssuesBody = '{"type":{"name":"'+ LinkLabels+'"},"inwardIssue":{"key":"'+linkKeys.trim()+'"},"outwardIssue":{"key":"'+currentKey+'"}}';
                                    HttpRequest request = new HttpRequest(); 
                                    request = CreateJIRAWrapper.CreateRequest('/rest/api/2/issueLink','POST' ,'application/json');
                                    request.setBody(LinkedIssuesBody);
                                    Http https = new Http();
                                    HTTPResponse response;
                                    response = https.send(request);
                                }
                            }
                        }
                        
                    } 
                    if( Schema.sObjectType.JiraIssue__c.fields.Status__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Status__c.isCreateable() ) {
                        jiraIssue.Status__c = '';
                    }
                    
                    if( Schema.sObjectType.JiraIssue__c.fields.Project__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable() ) {
                        jiraIssue.Project__c=projectName;
                    }
                    if( Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isCreateable() ) {
                        jiraIssue.Project_Id__c =  jiraIssue.Project__c!=null && String.IsnotEmpty(jiraIssue.Project__c) && jiraProjectsMap!=null && jiraProjectsMap.get(jiraIssue.Project__c)!=null && jiraProjectsMap.get(jiraIssue.Project__c).ProjectId__c!=null?
                            Decimal.valueOf(jiraProjectsMap.get(jiraIssue.Project__c).ProjectId__c):null;
                    }
                    
                    Map<String, Object> responseMap;
                    if(res.getStatusCode()==201 ){
                        
                        String response=res.getBody();
                        response=response.removeEnd('}');
                        response=response+','+body.removeStart('{');
                        responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        
                        
                        if( Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable() ){
                            jiraIssue.IssueId__c = Decimal.valueOf((String)responseMap.get('id'));
                        }
                        
                        if( Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable() ){
                            jiraIssue.IssueKey__c = (String)responseMap.get('key');
                        }
                        
                        if( Schema.sObjectType.JiraIssue__c.fields.name.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.name.isCreateable() ){ 
                            jiraIssue.name = (String)responseMap.get('key');
                        }
                        
                        if( Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable() ){
                            jiraIssue.Jira_Link__c = EndPoint +jiraIssue.IssueKey__c;
                        }
                        
                        if( Schema.sObjectType.JiraIssue__c.fields.Updated__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Updated__c.isCreateable() ){
                            jiraIssue.Updated__c = DateTime.now();
                        }
                        
                        if(jiraIssue.Created__c==null){
                            if( Schema.sObjectType.JiraIssue__c.fields.Created__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable() ) {
                                jiraIssue.Created__c = DateTime.now();
                            }
                        }
                        if( Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable() ) {
                            jiraIssue.JsonData__c = response;
                        }
                        
                        
                        try{
                            if(JiraIssue__c.sObjectType.getDescribe().isCreateable() && JiraIssue__c.sObjectType.getDescribe().isUpdateable()){
                                upsert jiraIssue;
                            }
                        }catch( Exception ex){
                            if(ex.getDmlType(0)==System.StatusCode.DUPLICATE_VALUE){                                    
                                if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                                    jiraIssue =[SELECT Name,Jsondata__c,Reporter__c,Project__c,Assignee__c,IssueKey__c,Summary__c, Description__c, IssueId__c, Id, Status__c,Priority__c,IssueType__c, Jira_Link__c,CaseNos__c   from JiraIssue__c where IssueId__c=:jiraIssue.IssueId__c];
                                } 
                            }else{
                                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                                GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Save Issue', Error);
                                
                            }
                        }
                        
                    }
                    else if((String.isNotEmpty(jiraIssue.IssueKey__c) && res.getStatusCode()==204)){
                        
                        jiraIssue.JsonData__c = body;
                        try{
                            if(schema.sObjectType.JiraIssue__c.isUpdateable()){
                                update jiraIssue;
                            }
                        }catch( Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Save Issue', Error);
                        }
                    }else{
                        errorMessage = res.getBody()+'_'+res.getStatus();
                        
                    }
                    
                    if(res.getStatusCode()==201 || ((String.isNotEmpty(jiraIssue.IssueKey__c) && res.getStatusCode()==204))){
                        if(!(JiraRelationship__c.sObjectType.getDescribe().isAccessible() && JiraRelationship__c.sObjectType.getDescribe().isUpdateable())){
                        }
                        else if(jiraIssueId==null){
                            
                            String NameSpace='';
                            if(Organization.sObjectType.getDescribe().isAccessible()){
                                List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization];
                                
                                if(Schema.sObjectType.Organization.fields.NameSpacePrefix.isAccessible() && !ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null){
                                    NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase();
                                }
                            }
                            Map<String,SobjectType> SchemaMap=Schema.getGlobalDescribe();
                            //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                            Map<String,SobjectField> relationshipfieldMap=SchemaMap.get('JiraRelationship__c').getDescribe().Fields.getMap();
                            
                            Map<String,Schema.DescribeFieldResult> fieldDescribeMethod=new Map<String,Schema.DescribeFieldResult>();
                            for(Schema.SObjectField field:relationshipfieldMap.values()){
                                Schema.DescribeFieldResult result= field.getDescribe();
                                fieldDescribeMethod.put(String.valueof(field).toLowerCase(),result);
                            }
                            
                            String RelationFieldName='';
                            RelationFieldName=genericObjectName;
                            if(RelationFieldName.contains('')) {
                                RelationFieldName=RelationFieldName.remove('');
                            }
                            if(RelationFieldName.containsIgnoreCase('__c')){
                                RelationFieldName= RelationFieldName.remove('__c');
                            }   
                            
                            if(RelationFieldName.contains('__'))RelationFieldName=RelationFieldName.substring(RelationFieldName.indexof('__')+2,RelationFieldName.length() );
                            
                            RelationFieldName=RelationFieldName.ToLowerCase()+'relation__c';
                            //NameSpace removed grz_sf__ to ''
                            if(fieldDescribeMethod.containskey(''+RelationFieldName)){RelationFieldName=''+RelationFieldName;} 
                            if(fieldDescribeMethod.containskey(NameSpace+'__'+RelationFieldName)){RelationFieldName=NameSpace+'__'+RelationFieldName; } 
                            
                            
                            String query='Select Id from JiraRelationship__c where JiraIssue__c=' + '\''+ String.escapeSingleQuotes(jiraIssue.Id) + '\'' + ' AND JiraIssueId__c =' + jiraIssue.IssueId__c  +' AND ' + RelationFieldName +'=' + '\'' + String.escapeSingleQuotes(genericObjectID)  + '\'';
                            
                            List<JiraRelationship__c> gJiraIssueList = new List<JiraRelationship__c>();
                            if(JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
                                gJiraIssueList =DataBase.Query(query);
                            }
                            JiraRelationship__c gJiraIssue = (gJiraIssueList!=null && gJiraIssueList.size()>0)?gJiraIssueList.get(0):null;
                            if(gJiraIssue==null && String.isNotEmpty(genericObjectID)){
                                
                                gJiraIssue = new JiraRelationship__c();
                                
                                if(!(Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isAccessible() && Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isCreateable())){ return null;}
                                else{
                                    if(Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isAccessible()){
                                        gJiraIssue.Jira_Issue_Link__c = jiraIssue.Jira_Link__c;
                                    }
                                }
                                if(!Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isAccessible()){ return null;}
                                else{
                                    if(Schema.sObjectType.JiraIssue__c.fields.Id.isAccessible()){
                                        gJiraIssue.JiraIssue__c = jiraIssue.Id;
                                    }
                                }
                                if(!(Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isAccessible() && Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isUpdateable())){return null;}
                                else{
                                    if(Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isAccessible()){
                                        gJiraIssue.JiraIssueId__c = jiraIssue.IssueId__c;
                                    }
                                }
                                
                                if(fieldDescribeMethod.get(RelationFieldName).Accessible==false){ return null; }
                                else{
                                    gJiraIssue.put(RelationFieldName,genericObjectID);
                                    
                                }
                                if(!(Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isAccessible() && Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isCreateable() &&
                                     Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isAccessible() &&
                                     Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isCreateable() &&
                                     fieldDescribeMethod.get(RelationFieldName).Accessible &&
                                     fieldDescribeMethod.get(RelationFieldName).Createable &&
                                     Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isAccessible() && Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isCreateable())){ return null;  }
                                else{
                                    try{
                                        if(schema.sObjectType.JiraRelationship__c.isCreateable()){
                                            insert gJiraIssue;
                                        }
                                    }catch(Exception ex){
                                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                                        GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, jiraIssue.Id, 'Save Issue', Error);
                                        
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
                else{
                    errorMessage+='You have added some fields in Jira field mapping that are not available on edit screen of Atlassian Jira layout. Please remove these field mapping (Admin Tab> Fields  > Click "-" > Save) OR add them in Atlassian Jira layout.<br/>';
                    String JSONContent = res.getBody();
                    
                    JSONParser parser = JSON.createParser(JSONContent);
                    Map<String,Object> errMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);
                    if(errMap.ContainsKey('errors')){
                        Object sterr = errMap.get('errors');
                        String err=json.serialize(sterr);
                        err=err.substring(err.indexOf('{')+1,err.lastIndexOf('}'));
                        if(err.contains(' ')){
                            err=  err.remove('"');
                            errorMessage+=System.label.EditAddjiraIssuecontroller_Label8 +'<br/>'+err;
                        }
                        
                    }
                    if(errMap.get('errorMessages')!=null){
                        errorMessage+=','+errMap.get('errorMessages');
                    }
                }
            } catch(System.CalloutException e){ 
                
                errorMessage = e.getMessage();
                GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Save Issue', errorMessage);
            } catch(Exception ex){
                
                errorMessage = ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, null, 'Save Issue', Errormessage);
            }
            
            if(String.isNotEmpty(errorMessage)){
                GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Save Issue', errorMessage);
                
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, errorMessage);
                ApexPages.addMessage(msg);
                return null; 
            }else{
                if(String.isEmpty(genericObjectID)){
                    
                    PageReference pageRef = new PageReference('/'+jiraIssueId);
                    return pageRef;
                }else{
                    if(mode=='cloneout'){
                        deletelinkedjira();
                    }
                    
                    PageReference pageRef;
                    if(jiraIssueId!=NULL && mode!='cloneout'){
                        //NameSpace removed Grz_sf__ViewJira to ViewJira
                        pageRef= new PageReference('/apex/ViewJira?jirakey='+jiraIssue.IssueKey__c+'&id='+jiraIssueId+'&genericObjectID='+genericObjectID);
                    }else{
                        
                        pageRef = new PageReference('/'+genericObjectID);
                    }
                    return pageRef;
                }
            }
        }catch(Exception ex){
            
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController','', '', null, null,null,null, null, JiraIssue__c.id!=null?JiraIssue.id:caseid, 'Constructor', Error);
            
        }
        return null;       
    }
    
    public PageReference deletelinkedjira(){
        list<jiraRelationship__c> Relationlist=new list<jiraRelationship__c> ();
        if(JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
            Relationlist =new list<jiraRelationship__c>([select id from jiraRelationship__c where JiraIssue__c=:jiraIssueId]);
        }
        if(!Relationlist.isEmpty()){
            try{
                if(schema.sObjectType.jiraRelationship__c.isdeletable()){
                    delete Relationlist;
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, null, 'Delete Linked Jira', Error);
                
            }
        }
        deletejira(jiraIssueId);
        return new PageReference('/'+caseObject);//Changed from caseID varibale to caseObject according to cohesity
    }
    
    @future
    public static void deletejira(id jiraIssueId){
        JiraIssue__c ji= new JiraIssue__c();
        ji.id=jiraIssueId;
        try{
            if(schema.sObjectType.JiraIssue__c.isdeletable()){
                delete ji;
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, ji.id, 'Delete Jira', Error);
            
        }
    }
    
    public void searchjiraissuenew(){
        
        searchJiraIssueList= new list<JiraIssue__c>();
        String searchText= ApexPages.currentPage().getParameters().get('searchText');
        if(searchText.length()>3){
            searchText='*'+searchText+'*';
            if(searchText!=Null &&searchText!=''){
                for(List<SObject> so:[FIND :searchText IN ALL FIELDS RETURNING Jiraissue__c(Id,summary__c,issuekey__c,Description__c)]){
                    searchJiraIssueList=so;
                }    
                
            }     
        }
    }
    
    public PageReference  linkcasewithjirakey(){
        
        String returnData;
        String linkjirakey= ApexPages.currentPage().getParameters().get('linkjirakey');
        if(genericObjectID!=Null && linkjirakey!=null){
            returnData= linkIssue(linkjirakey,genericObjectID,genericObjectName);
            if(returnData!=null && returnData!=''){
                PageReference PgRef = new PageReference('/'+genericObjectID);
                return PgRef;
            }
        }
        return null; 
    }
    
    
    Webservice static String linkIssue(String jiraIssueKey, Id genericObjID ,String genericObjectName){
        try{
            String Message = '';
            
            fetchJiraIssuesKeySet(genericObjID);
            
            if(!jiraIssueKeySet.contains(jiraIssueKey)){
                if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
                    Jira_login__c setting = [select id,Default_Jira_Project__c from Jira_login__c where name = 'JIRA' LIMIT 1];
                }
                JiraRelationship__c gJiraIssue = new JiraRelationship__c();
                JiraIssue__c jiraIssue;
                List<JiraIssue__c> giraIssueList=new List<JiraIssue__c> ();
                if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                    giraIssueList = new List<JiraIssue__c>([SELECT Name,Reporter__c,Project__c,Assignee__c,IssueKey__c,Summary__c, Description__c, Priority__c,IssueId__c, Id, Status__c, Jira_Link__c,IssueType__c,CaseNos__c FROM JiraIssue__c where IssueKey__c = :jiraIssueKey]);
                }
                if(giraIssueList.size()>0) jiraIssue = giraIssueList.get(0);
                
                else{
                    jiraIssue = JiraService.fetchJiraIssueByKey(jiraIssueKey, false, genericObjID);
                    
                }
                
                if(jiraIssue==null) Message = System.label.EditAddjiraIssuecontroller_Label9;
                else{
                    Boolean b=true;
                    String NameSpace='';
                    if(Organization.sObjectType.getDescribe().isAccessible()){
                        
                        List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
                        
                        if(Schema.sObjectType.Organization.fields.NameSpacePrefix.isAccessible() && !ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null){
                            NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase(); 
                        }
                        if(NameSpace!=NULL && NameSpace!='')
                            NameSpace=NameSpace.toLowerCase();
                    }
                    Map<String,SobjectType> SchemaMap=Schema.getGlobalDescribe();
                    //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                    Map<String,SobjectField> relationshipfieldMap=SchemaMap.get('JiraRelationship__c').getDescribe().Fields.getMap();
                    
                    Map<String,Schema.DescribeFieldResult> fieldDescribeMethod=new Map<String,Schema.DescribeFieldResult>();
                    for(Schema.SObjectField field:relationshipfieldMap.values()){
                        Schema.DescribeFieldResult res= field.getDescribe();
                        fieldDescribeMethod.put(String.valueof(field).ToLowerCase(),res);
                    }
                    
                    String RelationFieldName='';
                    RelationFieldName=genericObjectName;
                    
                    if (RelationFieldName.contains('')){
                        RelationFieldName=genericObjectName.remove('');
                    } 
                    
                    if(RelationFieldName.containsIgnoreCase('__c')){
                        RelationFieldName= RelationFieldName.removeEnd('__c');
                    }  
                    if(RelationFieldName.contains('__'))RelationFieldName=RelationFieldName.substring(RelationFieldName.indexof('__')+2,RelationFieldName.length() );
                    
                    RelationFieldName=RelationFieldName.ToLowerCase()+'relation__c';
                    
                    //NameSpace removed grz_sf__ to ''
                    if(fieldDescribeMethod.containskey(''+RelationFieldName)){RelationFieldName=''+RelationFieldName;} 
                    if(fieldDescribeMethod.containskey(NameSpace+'__'+RelationFieldName)){RelationFieldName=NameSpace+'__'+RelationFieldName;} 
                    
                    if(Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isAccessible() && Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isCreateable() ) { 
                        if(Schema.sObjectType.JiraIssue__c.fields.Id.isAccessible()){
                            gJiraIssue.JiraIssue__c = jiraIssue.Id;
                        }
                    }
                    if(Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isUpdateable() && Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isCreateable() ) {
                        if(Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isAccessible()){
                            gJiraIssue.JiraIssueId__c = jiraIssue.IssueId__c;
                        }
                    }
                    if(fieldDescribeMethod.get(RelationFieldName).Accessible){
                        gJiraIssue.put(RelationFieldName,genericObjID);
                    }
                    if(Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isUpdateable() && Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isCreateable() ){
                        if(Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isAccessible()){
                            gJiraIssue.Jira_Issue_Link__c = jiraIssue.Jira_Link__c;
                        }
                    }
                    
                    if(schema.sObjectType.JiraRelationship__c.isCreateable()){
                        
                        insert gJiraIssue;
                    }
                    
                    Message=jiraIssue.id;
                    
                    jiraIssueKeySet.add(gJiraIssue.JiraIssue__r.IssueKey__c);
                }
            }else{ Message = 'Error: JIRA Issue with this key already exists.';
                  
                 }
            return Message;
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, null, 'Link Issue', Error);
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            return null;
        }
    }
    
    
    /*****************************************************
fetch all the jiras linked with current object from salesforce
*****************************************************/
    private static void fetchJiraIssuesKeySet(Id genericObjId){
        
        jiraIssueKeySet = new Set<String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectName=genericObjId.getSObjectType().getDescribe().getName();
        map<String,Schema.SObjectField>  genericFieldMap = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField>  NewgenericFieldMap = new map<String,Schema.SObjectField>();  
        
        //Changed JiraRelationship__c namespace from JiraRelationship__c to JiraRelationship__c
        //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
        genericFieldMap= schemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
        
        String NameSpace='';
        if(Organization.sObjectType.getDescribe().isAccessible()){
            List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
            
            if(Schema.sObjectType.Organization.fields.NameSpacePrefix.isAccessible() && !ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null){
                NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase();
            }
        }
        for(String key:genericFieldMap.keySet()){
            String Inkey=key.tolowerCase();
            Inkey=Inkey.remove('grz_sf__');
            NewgenericFieldMap.put(Inkey,genericFieldMap.get(key));
        }
        
        String RelationFieldName;
        if (objectName.contains('')) {
            objectName=objectName.remove('');
        } 
        if(objectName.containsIgnoreCase('__c')){
            objectName= objectName.removeEnd('__c');
        }   
        if(objectName.contains('__'))objectName=objectName.substring(objectName.indexof('__')+2,objectName.length() );
        
        
        if(NewgenericFieldMap.containskey(objectName.tolowercase()+'relation__c')){ 
            RelationFieldName=String.valueOf(NewgenericFieldMap.get(objectName.tolowercase()+'relation__c'));
            //RelationFieldName=String.valueOf(NewgenericFieldMap.get(objectName.tolowercase()+'relation__c'));
        }else if(NewgenericFieldMap.containskey(/*NameSpace.ToLowerCase()+'__'+*/objectName.toLowerCase()+'relation__c')){
            RelationFieldName=String.valueOf(NewgenericFieldMap.get(/*NameSpace.ToLowerCase()+'__'+*/objectName.toLowerCase()+'relation__c'));
            //RelationFieldName=String.valueOf(NewgenericFieldMap.get(NameSpace.ToLowerCase()+'__'+objectName.toLowerCase()+'relation__c'));
        }
        String query ='SELECT Id, JiraIssue__c, JiraIssue__r.IssueId__c, JiraIssue__r.IssueKey__c, JiraIssue__r.IssueType__c, JiraIssue__r.Assignee__c, JiraIssue__r.description__c, JiraIssue__r.Priority__c, JiraIssue__r.Reporter__c, JiraIssue__r.Summary__c  FROM JiraRelationship__c where '+RelationFieldName+'= '+'\''+String.escapeSingleQuotes(genericObjId)+'\'';
        List<JiraRelationship__c> realtion=new List<JiraRelationship__c> ();
        if(JiraRelationship__c.sObjectType.getDescribe().isAccessible()){
            realtion=Database.query(query);
        }
        If(realtion!=NULL && realtion.size()>0 ){
            for(JiraRelationship__c jiraIssueInstance : realtion){
                jiraIssueKeySet.add(jiraIssueInstance.JiraIssue__r.IssueKey__c);
            }
        }
        
    }
    public PageReference getIssueLinkList() {
        try{
            fieldsToKey = new Map<String,String>();
            String issueLinkText= ApexPages.currentPage().getParameters().get('issueLinkText');
            
            String finalString = '';
            
            issueLinkText =issueLinkText.trim();
            issueLinkText=issueLinkText.replaceAll('  ',',');
            issueLinkText=issueLinkText.replaceAll(' ',',');        
            For(String text : issueLinkText.Split(',')){
                if(!finalString.contains(text))
                    finalString += text+','; 
            }
            issueLinkText = issueLinkText.removeEnd(',');
            HttpRequest req = new HttpRequest(); 
            Http http = new Http();
            HTTPResponse res;
            if(issueLinkField.JIRA_Field_Api_Name__c != null){
                String apiName='key,summary';
                apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search?jql=%28key%20in%20%28'+ issueLinkText+ '%29%29&fields='+apiName+'&maxResults=10', 'GET', 'application/json');
                res =http.send(req);
                if( res.getStatusCode()==200){
                    map<String,String> newMap = new map<String,String>();
                    String jsonInput = res.getBody();
                    
                    Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
                    
                    List<object> obj = new List<object>();
                    if(Main.containskey('issues')){
                        List<object> lobj=( List<object>)JSON.deserializeUntyped(JSON.serialize(Main.get('issues')));
                        for(Object o:lobj){
                            map<string,object> innerobj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                            map<string,object> newobj=( map<string,object>)JSON.deserializeUntyped(JSON.serialize(innerobj.get('fields')));
                            String summary = (String)newobj.get('summary');
                            if(summary.length() > 15)
                                summary = summary.Substring(0,10) + '...';
                            fieldsToKey.put(summary,(String)innerobj.get('key'));
                        }
                        
                        SizeOfMapLI = fieldsToKey.size();                    
                    }   
                }
                else{
                    GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Get issue link list', res.getbody());
                    
                }
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, null,'Get issue link list', Error);
            
        }
        
        return null;
    }
    
    public PageReference  getEpicLinkList(){
        
        fieldsToKey = new Map<String,String>();
        SizeOfMap = 0;
        String epicLinkText= ApexPages.currentPage().getParameters().get('epicLinkText');
        epicLinkText = EncodingUtil.urlEncode(epicLinkText,'UTF-8');
        
        HttpRequest req = new HttpRequest(); 
        Http http = new Http();
        HTTPResponse res;
        try{
            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible() && jiraField.JIRA_Field_Api_Name__c != null){
                String encodedSearchText = EncodingUtil.urlEncode(epicLinkText,'UTF-8').replaceAll('\\+','%20');
                String apiName='key,'+jiraField.JIRA_Field_Api_Name__c;
                apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');    
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search?jql=%28issuetype%3DEpic%20AND%20%22Epic%20Name%22%20~%20%27'+encodedSearchText+'%27%29%20&startAt=0&maxResults=10&fields='+apiName,'GET', 'application/json');
                res =http.send(req);
                
                if( res.getStatusCode()==200){
                    
                    map<String,String> newMap = new map<String,String>();                                            
                    String jsonInput = res.getBody();
                    Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
                    
                    List<object> obj = new List<object>();
                    if(Main.containskey('issues')){
                        List<object> lobj=( List<object>)JSON.deserializeUntyped(JSON.serialize(Main.get('issues')));
                        for(Object o:lobj){
                            map<string,object> innerobj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                            
                            
                            map<string,object> newobj=( map<string,object>)JSON.deserializeUntyped(JSON.serialize(innerobj.get('fields')));
                            
                            
                            fieldsToKey.put((String)newobj.get(jiraField.JIRA_Field_Api_Name__c),(String)innerobj.get('key'));
                        }
                        
                        SizeOfMap = fieldsToKey.size();
                    }   
                }else{
                    GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Get epic link list',res.getBody());
                }                                                   
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), null, 'Get epic link list',Error);
            
        }
        return null;
    }
    
    public void updateissuelist(){
        string issueName = ApexPages.currentPage().getParameters().get('issuename');
        string labelName = ApexPages.currentPage().getParameters().get('labelname');
        issuelinksset.add(issueName);
        
        if(IssuelinksMapValue.containsKey(labelName))
        {
            IssuelinksMapValue.get(labelName).add(issueName);
        }else
        {
            IssuelinksMapValue.put(labelName,new Set<String>{issueName});
            
        }
        fieldsToKey = new Map<String,String>(); 
        SizeOfMapLI=0;
    }
    public void updateissuelistdelete(){
        
        string issueName = ApexPages.currentPage().getParameters().get('deleteissuename');
        string labelName = ApexPages.currentPage().getParameters().get('deletelabelname');
        
        if(!IssuelinksMapValue.isEmpty()){
            for(String Key:IssuelinksMapValue.keySet()){
                if(Key==labelName){
                    set<String> temp=IssuelinksMapValue.get(key);
                    temp.remove(issueName);
                    for(string key1:temp)
                    {
                        IssuelinksMapValue.get(key).add(key1);
                    }
                }
            }
            
        }    }
    
    
    
    /***************************************
Mehtod To Convert the Data
***************************************/
    public static String ConvertDate(String RawDate){
        
        RawDate=RawDate.substring(0, RawDate.indexOf('.'));
        String[] splitDateTime = RawDate.split('T');
        String[] onlyDate = splitDateTime[0].split('-');
        String[] onlyTime = splitDateTime[1].split(':');
        
        DateTime dt = DateTime.newInstanceGMT(Integer.valueOf(onlyDate[0]),Integer.valueOf(onlyDate[1]), Integer.valueOf(onlyDate[2]), Integer.valueOf(onlyTime[0]), Integer.valueOf(onlyTime[1]), Integer.valueOf(onlyTime[2]));
        
        return  dt.format();
    }
    
    //modified on 03-07-2019
    Public Pagereference GetUserList(){
        //userlistbyname= new List<SelectOption>();
        //usermap = new map<String,map<String,String>>();
        Try{
            
            if(usersearchtext!=null && usersearchtext!=''){
                
                list<String> SearchMeta= usersearchtext.trim().split('__');
                
                DynamicFieldWrapper dynamic = sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]);
                
                if(SearchMeta[0]=='EmptyUser'){
                    //Add the selected user in Final User map,
                    //Empty user list
                    //If multiselect user then empty the slected value
                    sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).UserMapFinal.put(dynamic.username,dynamic.UserMap.get(dynamic.username));
                    sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).userlistbyname = new List<SelectOption>();
                    sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).usermap = new map<String,String>();
                    /*if(dynamic.mappedField.DataType__c=='multiuserpicker'){
sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).
get(SearchMeta[4]).username = '';
}*/
                    
                }
                if(SearchMeta[0]=='CleanUser'){
                    //remove the user from final map
                    sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).UserMapFinal.remove(SearchMeta[5]);
                    
                }
                if(SearchMeta[0]=='FetchUser'){
                    sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).userlistbyname = new List<SelectOption>();
                    sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).usermap= new map<String,String>();
                    
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/picker?query='+SearchMeta[1], 'GET', 'application/json');
                    
                    res = http.send(req);
                    String jsonInput;
                    jsonInput = res.getBody(); 
                    
                    if(res.getStatusCode()==200){
                        Map<String, Object> UserResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                        List<Object>userlist = (List<Object>)UserResponseMap.get('users');
                        if(!userlist.isEmpty()){
                            sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).userlistbyname.add(new SelectOption('',String.valueOf(UserResponseMap.get('header'))));
                        }else{
                            sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).UserMapFinal=new map<String,String>();
                            
                        }
                        for(Object user:userlist){   
                            Map<String, Object> UserMap = (Map<String, Object>)User;
                            
                            String value=String.valueOf(UserMap.get('displayName'));
                            if(UserMap.get('name')!=null && String.valueof(UserMap.get('name'))!=''){
                                value  +=' ('+ String.valueOf(UserMap.get('name'))+')';
                            }  
                            sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).userlistbyname.add(new SelectOption(value,value));
                            sectionToDynamicFieldWrapperListMap.get(SearchMeta[2]).get(Integer.valueOf(SearchMeta[3])).get(SearchMeta[4]).usermap.put(value,Json.serialize(UserMap));
                        }
                    }else{
                        GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(),null , null, 'Get users list', res.getbody());
                        
                    }
                }
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',null, null, null,null,null, null , null, null,'Get users list', Error);
            
        }
        return null;
        
    }
    
    public List<Object> fetchuserdetail(String useremail){
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/search?username='+useremail, 'GET', 'application/json');
        try{   
            res = http.send(req);
            String jsonInput;
            jsonInput = res.getBody();   
            if(res.getStatusCode()==200){
                userdata = (List<Object>)JSON.deserializeUntyped(jsonInput);
            }else{
                GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), null, null, 'Fetch User Detail', res.getBody());
                return null;
            }
            return userdata;
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('EditAddJiraIssueController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(),null , null, 'Fetch User Detail', Error);
            
        }
        return null;
    }
    public void InsertJiraLogs(){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}