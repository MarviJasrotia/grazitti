public class DynamicFieldWrapper {
    public map<String,String>usermap;
    public map<String,String>UserMapFinal{get;set;} 
    public List<SelectOption>userlistbyname{get;set;}   
    public String username{get;set;}   
    public Jira_ProjectFieldsMapping__c mappedField{get;set;}
    public String relatedReqIssue{get;set;}
    public string fieldValue{get;set;}
    public string masterFieldValue{get;set;}
    public string childFieldValue{get;set;}
    // public list<SelectOption> checkBoxOption{get;set;}
    public list<SelectOption> selectValues{get;set;} 
    public map<String,String> selectValueMap;
    public list<String> multiselectvalues{get;set;}
    public list<SelectOption> mastermapoption{get;set;}
    public map<String ,list<SelectOption>>masterchildmapoption{get;set;}
    public map<String ,string> mastermap;
    public map<String ,map<String,string>>masterchildmap;
    public map<String,String> clubChildMap{get;set;}
    public map<String,String> clubMasterMap{get;set;}
    public map<String,String> clubMasterMapRev;
    public boolean hasValues{get;set;}
    public String datetimevalue{get;set;}
    public String datevalue{get;set;}
    public date dat{get;set;}
    public datetime dattime{get;set;}
    public String ReporterUserName{get;set;}
    
    public DynamicFieldWrapper(Jira_ProjectFieldsMapping__c MappedField,String subtask)
    {   
        hasValues=false;
        relatedReqIssue='';
        clubChildMap= new map<String,String>();
        clubMasterMap = new map<String,String>();
        clubMasterMapRev = new map<String,String>();
        clubChildMap.put('None','None');
        clubMasterMap.put('None','None');
        clubMasterMapRev.put('None','None');
        multiselectvalues= new list<String>();
        This.mappedField = new Jira_ProjectFieldsMapping__c();
        
        selectValueMap = new  map<String,String>();
        selectValues = new list<SelectOption>();
        
        usermap = new map<String,String>();
        UserMapFinal = new map<String,String>();
        userlistbyname = new List<SelectOption>();  
        
        
        This.mappedField=MappedField;
        Set<String> RelatedReqIssueSet= new Set<String>();
        if(MappedField.ReqInIssueTypeData__c!=null && MappedField.ReqInIssueTypeData__c!=''){
            RelatedReqIssueSet.addAll(MappedField.ReqInIssueTypeData__c.split(','));
            RelatedReqIssueSet.remove('');
            RelatedReqIssueSet.remove(null);
            for(String st:RelatedReqIssueSet){
                relatedReqIssue+='--'+st+'--,';
            }
        }
        relatedReqIssue=relatedReqIssue.removeEnd(',');
        if(MappedField.IssueTypeData__c!=null && MappedField.IssueTypeData__c!='' && MappedField.IssueTypeData__c!='All'){
            MappedField.IssueTypeData__c = '--'+MappedField.IssueTypeData__c.replaceAll(',', '--,--')+'--';
        }
        mastermap= new map<String ,string>();
        mastermap.put('None', 'None');
        masterchildmap =new map<String ,map<String,string>>();
        masterchildmap.put('None',new map<String,String>{'None'=>'None'});
        mastermapoption = new list<SelectOption>();
        masterchildmapoption= new map<String,list<SelectOption>>();  
        // masterchildmapoption.put('None',new list<SelectOption>{new SelectOption('None','None')});
        // mastermapoption.add(new SelectOption('None','None'));
        if(This.mappedField!=null && (This.mappedField.IsArray__c||This.mappedField.DataType__c=='version') && This.mappedField.ProjectissueTypeData__c!=NULL && This.mappedField.DataType__c !='cascadingselect'){
            hasValues=true;
            JSONParser parser = JSON.createParser(This.mappedField.ProjectissueTypeData__c);
            
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    if(parser.getText()=='allowedValues'){
                        parser.nextToken() ;
                        while (parser.nextToken() != null) {
                            if(parser.getCurrentToken()==JSONToken.START_OBJECT){ 
                                while (parser.nextToken() != null) {
                                    if(parser.getCurrentToken()==JSONToken.FIELD_NAME){
                                        String fname=parser.getText();
                                        parser.nextValue();
                                        String fvalue=parser.getText();
                                        SelectOption s=new SelectOption(fvalue,fvalue);
                                        selectValueMap.put(fvalue,fname);
                                      
                                        Set<String> TempIssueSet= new Set<String>();
                                        if(String.isBlank(subtask))
                                        {
                                            if(This.mappedField.JIRA_Field_Api_Name__c=='issuetype' && This.mappedField.Jira_Project__r.IssueType__c!=null){
                                                List<String> TempIssueList= new List<String>();
                                                TempIssueList= This.mappedField.Jira_Project__r.IssueType__c.split(',');
                                                TempIssueSet.addAll(TempIssueList);
                                                if(This.mappedField.Jira_Project__r.DefaultIssueType__c!=null)
                                                    TempIssueSet.add(This.mappedField.Jira_Project__r.DefaultIssueType__c);
                                                TempIssueSet.remove(null);
                                                TempIssueSet.remove('');
                                                
                                            }
                                        }else{
                                            if(This.mappedField.JIRA_Field_Api_Name__c=='issuetype' && This.mappedField.Jira_Project__r.Subtask__c!=null){
                                                List<String> TempIssueList= new List<String>();
                                                TempIssueList= This.mappedField.Jira_Project__r.Subtask__c.split(',');
                                                TempIssueSet.addAll(TempIssueList);
                                                TempIssueSet.remove(null);
                                                TempIssueSet.remove('');
                                                
                                            }
                                            
                                        }
                                        
                                        if(This.mappedField.Jira_Project__r.Subtask__c!=null && This.mappedField.JIRA_Field_Api_Name__c!='issuetype'||
                                           TempIssueSet.isEmpty() ||
                                           (This.mappedField.JIRA_Field_Api_Name__c=='issuetype' && 
                                            TempIssueSet.contains(s.getvalue()))){
                                                
                                                selectValues.add(s);
                                                
                                            }  
                                    }
                                }
                            }
                        }
                    }
                }
            }
            selectValues.sort();
            
            if(This.mappedField.JIRA_Field_Api_Name__c!='issuetype'){
                SelectOption s=new SelectOption('',System.label.nonelabel2);
                if(This.mappedField.DataType__c.toLowerCase() =='radiobuttons')s=new SelectOption('',System.label.NoneLabel);
                selectValues.add(0, s);
            }
        } 
        if(This.mappedField.IsArray__c && This.mappedField.ProjectissueTypeData__c!=NULL &&  This.mappedField.DataType__c =='cascadingselect'){
            hasValues=true;
            
            map<string,object>  job= (map<string,object>)JSON.deserializeUntyped(This.mappedField.ProjectissueTypeData__c) ;
            List<object>  jobinner;
            for(String key:job.keyset()){
                object jo=job.get(key);
                jobinner= (List<object>)JSON.deserializeUntyped(JSON.serialize(jo)) ;
                
            }
            for(Object o:jobinner){
                
                map<string,object>  jmap= (map<string,object> )JSON.deserializeUntyped(JSON.serialize(o)) ;
                String mainkey='';
                for(String key:jmap.keyset()){
                    
                    if(key!='Children'){
                        mainkey=key;
                        mastermap.put(key,String.valueof(jmap.get(key)));
                        
                        
                    }
                    if(jmap.containskey('Children')){
                        List<object> jchildo= (List<object>)JSON.deserializeUntyped(JSON.serialize(jmap.get('Children'))) ;
                        
                        for(Object o1:jchildo){
                            map<string,object>  jchildmap= (map<string,object> )JSON.deserializeUntyped(JSON.serialize(o1)) ;
                            for(String ckey:jchildmap.keyset()){
                                map<String,String> cmap=new map<String,String>();
                                cmap.put(ckey,String.valueof(jchildmap.get(ckey)));
                                if(masterchildmap.containskey(mainkey)){
                                    map<String,String>ctemp= new map<String,String>();
                                    ctemp=masterchildmap.get(mainkey);
                                    ctemp.put(ckey,String.valueof(jchildmap.get(ckey)));
                                    masterchildmap.put(mainkey,ctemp);
                                }else{
                                    
                                    masterchildmap.put(mainkey,cmap);
                                }
                            }
                        }
                    }
                    else{
                        masterchildmap.put(mainkey,new  map<String,String>{'None'=>'None'});
                    }
                }
            } 
            
            
            for(String mkey:mastermap.keyset()){
                
                mastermapoption.add(new SelectOption(mkey,mastermap.get(mkey)));
                clubMasterMap.put(mkey,mastermap.get(mkey));
                clubMasterMapRev.put(mastermap.get(mkey),mkey);
            }
            for(String mckey:masterchildmap.keyset()){
                map<String,String> cmap=masterchildmap.get(mckey);
                if(!cmap.containsKey('None'))
                    masterchildmapoption.put(mckey,new list<SelectOption>{new SelectOption('None',System.label.NoneLabel)});
                
                for(String ckey:cmap.keyset()){
                    if(masterchildmapoption.containsKey(mckey)){
                        masterchildmapoption.get(mckey).add(new SelectOption(ckey,cmap.get(ckey)));
                    }else{
                        masterchildmapoption.put(mckey,new list<SelectOption>{new SelectOption(ckey,cmap.get(ckey))});
                    }
                    clubChildMap.put(ckey,cmap.get(ckey));
                }
            } 
            childFieldValue='None';
            masterFieldValue='None';
            
            
        }
        
    }
}