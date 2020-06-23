public class SearchJiraComponentController {
    
    public static string searchText;
    public static string prjctissues;
    public static string Startno;
    public static Integer indxv;
    public static Integer indxva;
    public static List<ProjectWrapper> wrapFieldList;
    public static string projectName;
    Public static set<String> SelectedProjects;
    Public static string[] SelectedProjectsSet;
    Public static string[] SelectedIssueTypeSet;  
    Public static string[] SelectedcomponentSet;
    public Integer wrappersize{get;set;}
    public static String keyProjects;
    public Id caseId{get;set;}
    public string srchbtn{get;set;}
    Set<String> selectedProjectsList=new Set<String>();
    public static Integer total;
    public static  integer index=0 ;
    public static integer SearchLimit =10;
    public static integer TotalPages;
    Public static Map<String, String> issuetypesOption;
    Public static Set<String> issueTypeSet;
    public static String issuetypes;
    public Integer offset;
    public static Boolean projectcount; 
    public static Boolean Loaded;
    public static String projectAndIssueTypeQuery;
    Integer count=0;
    public ID genericObjectID{get;set;}
    String genericObjectName{get;set;}
    
    
    @AuraEnabled
    public static MainWrapper SendSearchReqToJIRA(String searchtext,String componentList  ,String issueTypeList,String startAt,Integer indxval,string projectName){
        
        SelectedProjectsSet = new List<String>();
        SelectedIssueTypeSet = new List<String>();
        SelectedcomponentSet = new List<String>();
        List<String> issuetypesL=new List<String>();
        List< Object>  issueTypesObject=new List< Object>();
        List<String> components=new List<String>();
        List<String> filteredIssueTypeList=new List<String>();
        List<String> filteredComponentList=new List<String>();
        List<Object> componentObject =new List<object>();
        
        //Deserialise issueType 
        if(issueTypeList!='' && issueTypeList!=NULL){
            
            issueTypesObject = (List< Object>)JSON.deserializeUntyped(issueTypeList);
            
            for(object issue : issueTypesObject){  
                issuetypesL.add(string.valueof(issue));
            }
            for(String str: issuetypesL){
                if(str.contains(projectName+'_')){
                    filteredIssueTypeList.add(str.remove(projectName+'_'));
                }
            } 
        }
        
        //Deserialise Component
        if(componentList!='' && componentList!=NULL){
            
            componentObject = (List< Object>)JSON.deserializeUntyped(componentList);
            
            for(object issue : componentObject){  
                components.add(string.valueof(issue));
            }
            
            for(String str: components){
                if(str.contains(projectName+'_')){
                    filteredComponentList.add(str.remove(projectName+'_'));
                }
            }
        }
        
        SelectedProjectsSet.add(projectName);
        SelectedIssueTypeSet.addall(filteredIssueTypeList);
        SelectedcomponentSet.addAll(filteredComponentList);
        
        ProjectWrapper fld2=new ProjectWrapper();
        searchText=searchtext;
        indxv=indxval;
        Startno=startAt;
        
        
        
        
        
        Map<String,Jira_Project__c> project =new Map<String, Jira_Project__c>([select id,Subtask__c,Name,ProjectKey__c,ProjectId__c,DefaultIssueType__c,IssueType__c, Component__c from Jira_Project__c]);
        List<String> projectNames = new List<String>();
        projectNames.addAll(project.keySet());
        projectNames.sort();
        fld2.ProjectMap=new Map<String,Jira_Project__c>();
        // Create the Select Options.
        for (String proName : projectNames) {
            Jira_Project__c projectKey = project.get(proName);
            fld2.ProjectMap.put(projectKey.Name,projectKey);
        }
        
        Loaded=true;
        TotalPages=1;
        integer count=0;
        integer listsize=SelectedProjectsSet.size();      
        projectcount=false;
        try{
            if(searchText!=null && searchText!='' && searchText.length()>=4 && !searchText.contains('-')){
                
                wrapFieldList = new List<ProjectWrapper>();
                issuetypes='';        
                keyProjects ='';
                projectAndIssueTypeQuery='%28%20project%20in%20%28';
                
                Boolean flag=false;
                
                if(SelectedProjectsSet!=NULL && SelectedProjectsSet.size()>0){
                    
                    for(string pro : SelectedProjectsSet){
                        
                        if(fld2.ProjectMap.containsKey(pro)){
                            
                            String projectkey=fld2.ProjectMap.get(pro).ProjectKey__c;
                            projectAndIssueTypeQuery+='%27'+projectkey+'%27%29' ;
                            count++;
                            
                            Set<String> IssueTypesSet = new set<String>();
                            String issuetypes='';
                            if(fld2.ProjectMap.get(pro.trim()).IssueType__c!=null){
                                IssueTypesSet.addAll(fld2.ProjectMap.get(pro.trim()).IssueType__c.split(','));
                                for(String type:IssueTypesSet){
                                    if(SelectedIssueTypeSet.contains(type)){
                                        flag=true;
                                        if(issuetypes==''){
                                            issuetypes ='%28' + '%27'+ type.replaceAll(' ','%20') +'%27'  ;
                                        }else{
                                            issuetypes+= '%2C' + '%27'+ type.replaceAll(' ','%20') +'%27'  ; 
                                        }
                                    }
                                }
                                
                                if(issuetypes != ''){
                                    issuetypes+='%29';
                                    projectAndIssueTypeQuery+='%20AND%20issuetype%20in%20'+issuetypes;
                                }
                                
                            }
                            
                        }
                        
                        if(count<listsize)
                            projectAndIssueTypeQuery+='%20OR%20%28project%20in%20%28';
                    }
                    
                    
                    if(SelectedcomponentSet!=NULL && SelectedcomponentSet.size()>0){
                        
                        String component='';
                        for(String cmp : SelectedcomponentSet){
                            if(component==''){
                                component ='%28' + '%27'+ cmp.replaceAll(' ','%20') +'%27'  ;
                            }else{
                                component+= '%2C' + '%27'+ cmp.replaceAll(' ','%20') +'%27'  ; 
                            }
                            
                        }
                        
                        if(component != ''){
                            component+='%29';
                            projectAndIssueTypeQuery+='%20AND%20component%20in%20'+component;
                        }
                    }
                    
                }
                projectAndIssueTypeQuery+='%29';
            }else if(searchText.Trim().contains('-')){
                
                projectAndIssueTypeQuery='%20project%20in%20%28';
                if(SelectedProjectsSet!=NULL && SelectedProjectsSet.size()>0){
                    for(string pro : SelectedProjectsSet){
                        
                        if(fld2.ProjectMap.containsKey(pro)){
                            
                            String projectkey=fld2.ProjectMap.get(pro).ProjectKey__c;
                            projectAndIssueTypeQuery+='%27'+projectkey+'%27' ;
                            count++;
                            
                            if(count<listsize)
                                projectAndIssueTypeQuery+='%2c';
                            
                        }
                        projectAndIssueTypeQuery+='%29';        
                    }
                }
                
            }  
            
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SearchJiraComponentController',null, null, null,null,null, null , null, null, 'SendSearchReqToJIRA', Error);    
        }
        
        
        MainWrapper Mainwrp1= new MainWrapper();
        if(searchText!=null){
            if(startno==null){
                Mainwrp1=SearchJiraData(searchText,'0',indxv);
            }else{
                Mainwrp1=SearchJiraData(searchText,startno,indxv);  
            }
        }
        
        return Mainwrp1;
    }
    
    @AuraEnabled
    public static MainWrapper SearchJiraData(String searchTextparam,String startAt,Integer indexva){
        
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        HttpRequest req = new HttpRequest(); 
        try{
            string searchText=searchTextparam.Trim();
            String encodedSearchText = EncodingUtil.urlEncode(searchText,'UTF-8');
            
            String apiName ='id,issuetype,summary,description,status,components' ;
            apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');
            indexva=indexva;
            if(searchText.contains('+')){
                
                List<string> searchlist=searchText.split('\\+');
                integer listsize=searchlist.size();
                
                integer count=0;
                string query='TEXT~%27';
                if(searchlist.size()>0){
                    for(string sl:searchlist){
                        query+=sl.Trim()+'%2A%27'; 
                        count++;
                        if(count<listsize)
                            query+='%20OR%20TEXT~%27';
                    }
                }
                
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search?jql=%28'+query+'%29%20AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
            }else if(searchText.contains(' ')){
                
                encodedSearchText=encodedSearchText.replaceAll('\\+','%20');
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=TEXT~%27'+encodedSearchText+'%2A%27AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
                
            }else if(searchText.contains('-')){
                
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=%28KEY%3D'+encodedSearchText+'%20OR%20TEXT~%27'+encodedSearchText+'%2A%27%29AND'+projectAndIssueTypeQuery+'&fields='+apiName, 'GET', 'application/json');
                
            }else{
                
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/search/?jql=TEXT~%27'+encodedSearchText+'%2A%27AND'+projectAndIssueTypeQuery+'%20&maxResults='+SearchLimit+'&startAt='+startAt+'&fields='+apiName, 'GET', 'application/json');
                
            }
            
            res = http.send(req);
            String jsonInput;
            jsonInput = res.getBody();
            
            wrapFieldList = new List<ProjectWrapper>();
            if(res.getStatusCode()==200){
                
                Map<String, Object> projectResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
                List<Object> issueMap = (List<Object>)projectResponseMap.get('issues');
                total=(Integer)projectResponseMap.get('total');
                TotalPages=Integer.valueOf(math.ceil(total/SearchLimit));
                if(math.mod(total,SearchLimit)>0 ){
                    TotalPages++;
                    
                }  
                
                integer maxResults=(Integer)projectResponseMap.get('maxResults');
                Map<String, Object> IssueKeyToFieldsMap = new Map<String, Object>();
                Map<String, Object> issueTypeDataMap = new Map<String, Object>();
                if(issueMap.isEmpty()){
                    MainWrapper Mainwrp0= new MainWrapper();
                    Mainwrp0.fieldWrapperList=wrapFieldList; 
                    return Mainwrp0;
                }
                for(Object issue : issueMap){
                    
                    issueTypeDataMap = (Map<String, Object>)issue;
                    if(issueTypeDataMap.get('fields') !=null){
                        IssueKeyToFieldsMap.put((String)issueTypeDataMap.get('key'), (Object)issueTypeDataMap.get('fields'));
                    }
                }
                for(String innerKey: IssueKeyToFieldsMap.keySet()){
                    
                    
                    Object JsonObj=IssueKeyToFieldsMap.get(innerKey);
                    string jsonstring = JSON.serialize(JsonObj);
                    
                    Map<String, Object> descMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
                    
                    String descp = String.valueOf(descMap.get('description'));
                    String summary = String.valueOf(descMap.get('summary'));
                    object jirastatusObject =(object)descMap.get('status');
                    List<Object> componentList=(List<object>)descMap.get('components');
                    String storeComponents='';
                    
                    for(object obj: componentList){
                        
                        Map<String,object> comp=(Map<String,Object>)obj;
                        
                        if(comp.containsKey('name')){
                            if(storeComponents==''){
                                storeComponents=String.valueof(comp.get('name'));
                            }else{
                                storeComponents+=','+String.valueof(comp.get('name'));
                            }
                        }
                    }
                    
                    Map<String, Object> jiraStatusMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jirastatusObject));
                    string jirastatus='';
                    if(jiraStatusMap.containskey('name'))
                        jirastatus=string.valueof(jiraStatusMap.get('name'));
                    
                    object issuetypeobject = (object)descMap.get('issuetype');
                    Map<String, Object> issueTypeMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(issuetypeobject));
                    String issuetype=string.valueof(issueTypeMap.get('name'));
                    
                    ProjectWrapper wrapFields = new ProjectWrapper();
                    wrapFields.status = jirastatus;
                    wrapFields.key = innerKey;
                    wrapFields.Summary = summary;
                    wrapFields.components=storeComponents;
                    wrapFields.Description =descp;
                    wrapFields.Issuetype=issuetype;
                    wrapFieldList.add(wrapFields);
                    
                }
                
            }else{
                GenerateJiraLogs.CreateLogRealTime('SearchJiraComponentController', req.getEndPoint() , req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody(), '', null, 'SearchJiraData', res.getBody());
            }
            
            MainWrapper Mainwrp= new MainWrapper();
            Mainwrp.fieldWrapperList=wrapFieldList;
            Mainwrp.indexval=indexva;
            Mainwrp.totalpage=TotalPages;
            
            return Mainwrp;
        } catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SearchJiraComponentController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'SearchJiraData', Error);   
        }
        return null; 
    } 
    
    
    @AuraEnabled
    public Static Map<String,ProjectWrapper> fetchAllProjects(){
        try{
            ProjectWrapper fld=new ProjectWrapper();
            fld.options = new Map<String, List<String>>();
            Map<String, Jira_Project__c> project =new Map<String,Jira_Project__c>([select id,Subtask__c,Name,ProjectKey__c,ProjectId__c,DefaultIssueType__c,IssueType__c, Component__c from Jira_Project__c]);
            List<String> projectNames = new List<String>();
            projectNames.addAll(project.keySet());
            projectNames.sort();
            fld.ProjectMap=new Map<String,Jira_Project__c>();
            
            // Create the Select Options.
            Map<String,ProjectWrapper> wrapperMap = new Map<String,ProjectWrapper>();
            for (String proName : projectNames) {
                Jira_Project__c projectKey = project.get(proName);
                fld.ProjectMap.put(projectKey.Name,projectKey);
                ProjectWrapper proWrapp = new ProjectWrapper();
                proWrapp.name =projectKey.ProjectKey__c ;
                proWrapp.label =projectKey.Name ;
                proWrapp.expanded =true ;
                proWrapp.defaultissuetype=projectKey.DefaultIssueType__c;
                
                List<FieldTypeWrapper> fldWrapper = new List<FieldTypeWrapper>();
                for(String a:projectKey.IssueType__c.split(',')){
                    FieldTypeWrapper wrp = new FieldTypeWrapper(); 
                    wrp.name = a ;
                    wrp.label = a ;
                    wrp.expanded = false ;
                    fldWrapper.add(wrp);
                }
                proWrapp.items =fldWrapper ;
                wrapperMap.put(proWrapp.name,proWrapp);
            }
            
            return wrapperMap;
        } catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SearchJiraComponentController',null, null, null,null,null, null , null, null, 'fetchAllProjects', Error);   
        }
        return null;
    }
    
    @AuraEnabled
    public Static List<FieldTypeWrapper> fetchComponents(string projectKey){
        List<FieldTypeWrapper> cmpWrapper = new List<FieldTypeWrapper>();
        ProjectWrapper wrapdata=new ProjectWrapper();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        try{
            req=createjiraWrapper.CreateRequest('/rest/api/2/project/'+projectKey+'/components', 'GET', 'application/json');
            res = http.send(req); 
            String jsonInput;
            if(res.getStatusCode()==200){
                jsonInput = res.getBody();
                
                List<Object> componentList = (List<Object>)JSON.deserializeUntyped(jsonInput);
                Map<String, Object> componentMap=new Map<String, Object>();
                for(object cmp : componentList){
                    componentMap =(Map<String, Object>)cmp;
                    FieldTypeWrapper wrp=new FieldTypeWrapper();
                    wrp.name = String.valueof(componentMap.get('name')) ;
                    wrp.label = String.valueof(componentMap.get('id')) ;
                    wrp.expanded = false ;
                    cmpWrapper.add(wrp);
                }
                
                return cmpWrapper;
            }else{
                GenerateJiraLogs.CreateLogRealTime('SearchJiraComponentController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'fetchComponents', res.getBody());   
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('SearchJiraComponentController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, null, 'fetchComponents', Error);   
        }
        return null; 
    }
    
    public class ProjectWrapper{
        @AuraEnabled public string Key;
        @AuraEnabled public string Summary;
        @AuraEnabled public string Description;
        @AuraEnabled public String Issuetype;
        @AuraEnabled public String Status;
        @AuraEnabled public String components;
        @AuraEnabled public  Map<String, List<String>> options;
        @AuraEnabled public  Map<String,Jira_Project__c> ProjectMap;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String defaultissuetype;
        @AuraEnabled public String Link;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public Boolean fetchedcomponent;
        
        @AuraEnabled public List<FieldTypeWrapper> items;
        @AuraEnabled public List<FieldTypeWrapper> component;
    }
    
    public class FieldTypeWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean expanded;
    }
    
    public class MainWrapper{
        @AuraEnabled public Integer indexval;
        @AuraEnabled public Integer totalpage;
        @AuraEnabled public List<ProjectWrapper> fieldWrapperList;
        
    }
    
    @AuraEnabled
    public static MainWrapper nextPage(String searchtext,String componentList  ,String issueTypeList,Integer indexv,string projectName) {
        searchText=searchtext;
        //prjctissues=param;
        index=indexv;
        
        index+=1;
        MainWrapper Mainwrp2= new MainWrapper();
        Mainwrp2=SendSearchReqToJIRA(searchText,componentList,issueTypeList,String.valueOF(index*SearchLimit),index,projectName);
        
        return Mainwrp2;
    }
    
    @AuraEnabled
    public static MainWrapper previousPage(String searchtext,String componentList  ,String issueTypeList,Integer indexv,string projectName) {
        searchText=searchtext;
        //prjctissues=param;
        index=indexv;
        if(index!=0){
            index-=1;
        }
        MainWrapper Mainwrp3= new MainWrapper();
        Mainwrp3=SendSearchReqToJIRA(searchText,componentList,issueTypeList,String.valueOF(index*SearchLimit),index,projectName);
        return Mainwrp3;
    }
    
    @AuraEnabled
    public static void linkcasewithjirakey(string row,ID caseID){
        
        String returnData;
        String linkjirakey= row;
        String genericObjectName;
        if(caseID!=null){
            genericObjectName=caseID.getSObjectType().getDescribe().getName();
        }
        if(caseID!=null && linkjirakey!=null){
            returnData= EditAddJiraIssueController.linkIssue(linkjirakey,caseId,genericObjectName);
        }
    }
    
}