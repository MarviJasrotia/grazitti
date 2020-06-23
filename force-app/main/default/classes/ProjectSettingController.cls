public with sharing class ProjectSettingController {
    Public Boolean AllJobCompleted {get;set;}
    Public List < ProjectWrapper > projectsList{get;set;}
    public Map < String, Jira_Project__c > jiraProjectMap;
    public Map < String, Jira_Project__c > jiraProjectMapCopy;
    
    
    public  List < ProjectWrapper> projectList;
    public List < SelectOption > options{get;set;}
    public String jobname{get;set;}
    public JiraSalesforceDetail__c DefaultProject{get;set;}
    public Boolean projectSuccess{get;set;}
    
    public ProjectSettingController(){
        init();
    }
    public void init(){
        AllJobCompleted=false;
        projectsList = new List < ProjectWrapper > ();
        jiraProjectMap = new Map < String, Jira_Project__c >();
        jiraProjectMapCopy = new Map < String, Jira_Project__c >();
        // = new map<String,Jira_Project__c>();
        projectList = new List < ProjectWrapper>();
        options = new List < SelectOption >();
        jobname='';
        DefaultProject = new JiraSalesforceDetail__c();
        projectSuccess=false;
    }
    
    public void onProjectLoad(){
        init();
        DefaultProject= JiraSalesforceDetail__c.getall().get('DefaultProject')!=null?JiraSalesforceDetail__c.getall().get('DefaultProject'):new JiraSalesforceDetail__c(Name='DefaultProject');
        fetchProjectData();
        CreateProjectWrapper();
    }
    
    public void fetchProjectData(){
        projectList = JiraService.fetchProjectData();
    }
    
    public string CreateProjectWrapper() {
        
        jiraProjectMap = new Map < String, Jira_Project__c >();
        jiraProjectMapCopy = new Map < String, Jira_Project__c >();
        for (Jira_Project__c projectInstance:[select id,Name,ProjectKey__c,Subtask__c ,ProjectId__c,Write__c,IssueType__c,DefaultIssueType__c ,Read__c from Jira_Project__c LIMIT 1000]) {
            jiraProjectMap.put(projectInstance.ProjectKey__c, projectInstance);
            projectSuccess=true;
        }
        for (Jira_Project__c projectInstance:[select id,Name,ProjectKey__c,Subtask__c ,ProjectId__c,Write__c,IssueType__c,DefaultIssueType__c ,Read__c from Jira_Project__c LIMIT 1000]) {
            jiraProjectMapCopy.put(projectInstance.ProjectId__c, projectInstance);
        }
        projectsList = new List < ProjectWrapper > ();
        for (ProjectWrapper Wrapper: projectList){ 
            
            ProjectWrapper projectWrapperInstance = new ProjectWrapper();
            Jira_Project__c project = new Jira_Project__c();
            if (jiraProjectMap.get(Wrapper.Project.ProjectKey__c) != null) {
                projectWrapperInstance.selected = true;
                project = jiraProjectMap.get(Wrapper.Project.ProjectKey__c);
            } else {
                
                project = new Jira_Project__c();
                project=Wrapper.Project;
                projectWrapperInstance.selected = false;
            }
            
            projectWrapperInstance.project = project;
            projectWrapperInstance.IssueList=Wrapper.IssueList;
            
            projectWrapperInstance.IssueSelectList= Wrapper.IssueSelectList;
            projectWrapperInstance.IssueSubList= Wrapper.IssueSubList;
            
            projectWrapperInstance.IssueStdList= Wrapper.IssueStdList;
            
            if(project.IssueType__c!=null||project.Subtask__c!=null){
                
                // projectWrapperInstance.SelectedIssues=project.IssueType__c+(project.IssueType__c!=null?',':' ')+(project.Subtask__c!=null?project.Subtask__c:'');
                projectWrapperInstance.SelectedIssues=(project.IssueType__c==null?'':project.IssueType__c)+(project.IssueType__c!=null?',':'')+(project.Subtask__c!=null?project.Subtask__c:'');               
                
                projectWrapperInstance.SelectedIssues=projectWrapperInstance.SelectedIssues.removeend(',');             
            }else{
                projectWrapperInstance.SelectedIssues='';
            }
            projectsList.add(projectWrapperInstance);
        }
        
        updateProjectOptions();
        return null;
    }
    /**
* fills the options list with the project when the any project is selected for map with salesforce 
*/
    public PageReference updateProjectOptions(){
        options = new List < SelectOption > ();
        
        for(ProjectWrapper projectWrapperInstance :projectsList){
            if(projectWrapperInstance.project.write__c){
                options.add(new SelectOption(projectWrapperInstance.project.ProjectKey__c,projectWrapperInstance.project.Name));
            }
            
        }
        if(options.isEmpty()){
            options.add(new SelectOption('None', System.label.nonelabel2));
        }
        return null;
    }
    public PageReference saveProjects() {
        String Projectkeys='';
        Set<id> Proids = new Set<id>();
        Set<id> ProjectwithchangedIssueType = new Set<id>();
        
        try {
            
            if (!(Jira_Project__c.sObjectType.getDescribe().isAccessible()
                  && Jira_Project__c.sObjectType.getDescribe().isCreateable() &&
                  Jira_Project__c.sObjectType.getDescribe().isUpdateable() && 
                  Jira_Project__c.sObjectType.getDescribe().isDeletable())) {
                return null;
            } else {
                
                List < Jira_Project__c > projects = new List < Jira_Project__c > ();
                List < Jira_Project__c > deleteProjects = new List < Jira_Project__c > ();
                Set<Id> OldProjects= new Set<Id>();
                if(Schema.sObjectType.JiraSalesforceDetail__c.isupdateable() && Schema.sObjectType.JiraSalesforceDetail__c.isCreateable()  ){
                    upsert DefaultProject;
                }  
                if (!(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()
                      && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isCreateable() 
                      && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isUpdateable()
                      && Schema.sObjectType.Jira_Project__c.fields.Id.isAccessible())) {
                    return null;
                } else {
                    for (ProjectWrapper projectWrapperInstance: projectsList) {
                        if (projectWrapperInstance.selected) {
                            if(Schema.sObjectType.Jira_Project__c.fields.Read__c.isCreateable()&&
                               Schema.sObjectType.Jira_Project__c.fields.Read__c.isUpdateable()){  
                                   projectWrapperInstance.project.Read__c=true;
                               }
                            if(projectWrapperInstance.project.id!=Null)OldProjects.add(projectWrapperInstance.project.id);
                            String commaSepratedSubList='';
                            String commaSepratedList='';
                            String IssueTypeList='';
                            for(String str:projectWrapperInstance.IssueSubList){
                                commaSepratedSubList += str + ',' ;
                            }
                            commaSepratedSubList = commaSepratedSubList.subString(0,commaSepratedSubList.length());
                            commaSepratedSubList=commaSepratedSubList.removeEnd(',');
                            for(String str:projectWrapperInstance.IssueList){
                                commaSepratedList += str + ',' ;
                            }
                            commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length());
                            commaSepratedList=commaSepratedList.removeEnd(',');
                            IssueTypeList += projectWrapperInstance.SelectedIssues + ',' ;
                            IssueTypeList = IssueTypeList.subString(0,IssueTypeList.length());
                            IssueTypeList=IssueTypeList.removeEnd(',');
                            
                            List<String> mergeList1=new List<String>();
                            List<String> mergeList2=new List<String>();
                            List<String> mergeList=new List<String>();
                            List<String> mergeSubList=new List<String>();
                            
                            String[] s=IssueTypeList.split(',');
                            String[] s1=commaSepratedSubList.split(',');
                            
                            mergeList1.addAll(s);
                            mergeList2.addAll(s1);
                            
                            for(String str:mergeList1){
                                if(mergeList2.contains(str)){
                                    mergeSubList.add(str);   
                                }else{
                                    mergeList.add(str);
                                }
                            }
                            String stdIssues='';
                            
                            for(String str: mergeList){
                                stdIssues += str + ',' ;
                            }
                            stdIssues = stdIssues.subString(0,stdIssues.length());
                            stdIssues=stdIssues.removeEnd(',');
                            String subIssues='';
                            for(String str1:mergeSubList){
                                subIssues += str1 + ',' ;
                            }
                            subIssues = subIssues.subString(0,subIssues.length());
                            subIssues=subIssues.removeEnd(',');
                            if(Schema.sObjectType.Jira_Project__c.fields.IssueType__c.isCreateable()&&
                               Schema.sObjectType.Jira_Project__c.fields.IssueType__c.isUpdateable()){  
                                   projectWrapperInstance.project.IssueType__c=stdIssues;
                               }
                            if(Schema.sObjectType.Jira_Project__c.fields.Subtask__c.isCreateable()&&
                               Schema.sObjectType.Jira_Project__c.fields.Subtask__c.isUpdateable()){  
                                   projectWrapperInstance.project.Subtask__c=subIssues;
                               }
                            if((((projectWrapperInstance.project.IssueType__c==null)||
                                 (projectWrapperInstance.project.IssueType__c==''))&&
                                ((projectWrapperInstance.project.Subtask__c==null)||
                                 (projectWrapperInstance.project.Subtask__c=='')))&&
                               ((projectWrapperInstance.project.DefaultIssueType__c!=null)&&
                                (projectWrapperInstance.project.DefaultIssueType__c!=''))){
                                    ErrorMessage(System.label.ProjectSettingController_Label2); 
                                    return null;
                                }
                            
                            
                            if(((projectWrapperInstance.project.DefaultIssueType__c==null)||
                                (projectWrapperInstance.project.DefaultIssueType__c==''))&&
                               (((projectWrapperInstance.project.IssueType__c!=null)&&
                                 (projectWrapperInstance.project.IssueType__c!=''))||
                                ((projectWrapperInstance.project.Subtask__c!=null)&&
                                 (projectWrapperInstance.project.Subtask__c!='')))){
                                     ErrorMessage(System.label.ProjectSettingController_Label1); 
                                     return null;
                                 }
                            
                            
                            if(jiraProjectMapCopy.get(projectWrapperInstance.project.ProjectId__c)!= null){
                                String ProjectId=projectWrapperInstance.project.ProjectId__c;
                                Set<String> CurrentIssueType = new Set<String>();
                                Set<String> UpdatedIssueType = new Set<String>();
                                
                                if(jiraProjectMapCopy.get(ProjectId).IssueType__c!=null &&
                                   jiraProjectMapCopy.get(ProjectId).IssueType__c!=''){
                                       CurrentIssueType.addAll(jiraProjectMapCopy.get(ProjectId).IssueType__c.split(','));
                                   }
                                if(jiraProjectMapCopy.get(ProjectId).Subtask__c!=null &&
                                   jiraProjectMapCopy.get(ProjectId).Subtask__c!=''){
                                       CurrentIssueType.addAll(jiraProjectMapCopy.get(ProjectId).Subtask__c.split(','));
                                   }
                                
                                if(projectWrapperInstance.project.IssueType__c!=null&&
                                   projectWrapperInstance.project.IssueType__c!=''){
                                       UpdatedIssueType.addAll(projectWrapperInstance.project.IssueType__c.split(','));
                                   }
                                if(projectWrapperInstance.project.Subtask__c!=null &&
                                   projectWrapperInstance.project.Subtask__c!=''){
                                       UpdatedIssueType.addAll(projectWrapperInstance.project.Subtask__c.split(','));
                                   }
                                List<String> CurrentIssueTypeList= new List<String>();
                                CurrentIssueTypeList.addAll(CurrentIssueType);
                                List<String> UpdatedIssueTypeList= new List<String>();
                                UpdatedIssueTypeList.addAll(UpdatedIssueType);
                                UpdatedIssueType.removeAll(CurrentIssueTypeList);
                                CurrentIssueType.removeAll(UpdatedIssueTypeList);
                                
                                if(UpdatedIssueType.size()>0||CurrentIssueType.size()>0){
                                    ProjectwithchangedIssueType.add(projectWrapperInstance.project.id);
                                }
                            }
                            projects.add(projectWrapperInstance.project);
                            Projectkeys+=projectWrapperInstance.project.ProjectKey__c+',';
                        } 
                        else if (jiraProjectMap.get(projectWrapperInstance.project.ProjectKey__c) != null && projectWrapperInstance.project.Id != null) {
                            deleteProjects.add(new Jira_Project__c(Id = projectWrapperInstance.project.Id,ProjectKey__c=projectWrapperInstance.project.ProjectKey__c));
                        }
                    }
                    Projectkeys=Projectkeys.removeEnd(',');
                    if (projects.size() > 0) {
                        if(Schema.sObjectType.Jira_Project__c.isUpdateable() && Schema.sObjectType.Jira_Project__c.isCreateable()){
                            upsert projects;
                        }
                        projectSuccess=true;
                        
                    }
                    if (deleteProjects.size() > 0) {
                        List<String> ContentTitle= new List<String>();
                        for(Jira_Project__c JP:deleteProjects){
                            String Title=JP.Projectkey__c+'_Json.txt';
                            String Title1=JP.Projectkey__c+'_NotAllowedJson.txt';
                            ContentTitle.add(Title);
                            ContentTitle.add(Title1);
                        }
                        List<ContentDocument> CdList = new List<ContentDocument>();
                        CdList = [select id from ContentDocument where Title in :ContentTitle];
                        if(!CdList.isEmpty()){
                            
                            if(Schema.sObjectType.ContentDocument.isDeletable()){
                                delete CdList;
                            }
                        }  
                        
                        if(Schema.sObjectType.Jira_Project__c.isDeletable()){
                            delete deleteProjects;
                        }
                    } 
                    
                    Set<Id>  JiraProjectsMap = new Set<Id>();
                    for(Jira_Project__c Jp:projects){
                        //|| ProjectwithchangedIssueType.contains(Jp.id)   
                        if(!OldProjects.contains(Jp.id)|| ProjectwithchangedIssueType.contains(Jp.id)){
                            JiraProjectsMap.add(Jp.id);
                        } 
                    }
                    if(!JiraProjectsMap.isEmpty()){
                        StoreJsonFile batch=new StoreJsonFile(JiraProjectsMap);
                        Database.executeBatch(batch,1);
                    }
                    
                    // createStaticFields();
                    CreateProjectWrapper();
                }
            }
            
        } catch (Exception ex) {
            String Error=System.label.Cause_Label +ex.getCause()+'\n'+System.label.LineNumber_Label+ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            ErrorMessage( ex.getMessage() + '\t' + ex.getLineNumber());
            GenerateJiraLogs.CreateLogRealTime('ProjectSettingController',null, null, null,null,null, null , null, null, 'SaveProjects', Error);
            
        }
        return null;
    }
    
    public PageReference AsyncJobDone(){
        Integer i=[SELECT  count() FROM AsyncApexJob where MethodName =:jobname and Status in ('Queued','Preparing','Processing')  and jobType='Future' ];
        if(i==0){
            AllJobCompleted=true; 
        }
        return null;
    }
    public static void ErrorMessage(String Error){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Error );
        ApexPages.addMessage(msg); 
    }
}