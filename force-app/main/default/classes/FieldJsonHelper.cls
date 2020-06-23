public class FieldJsonHelper {
    Boolean  bb= false;
    public Static String getFieldData(String key,map<String, Object>JsonData){
        map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
      
        String data=''; 
        Boolean  bb=false;
        
        if(key.toLowerCase()=='key'||key.toLowerCase()=='link'){
            if(key.toLowerCase()=='key' && JsonData.get('key')!=null){
                data=String.valueOf(JsonData.get('key'));
            }else if(key.toLowerCase()=='link' &&  JsonData.get('self')!=null){
                data=JiraService.fetchDomain(String.valueOf(JsonData.get('self')))+'/browse/'+JsonData.get('key');
            }
        }else{
            try{
                if(!bb){
                   
                    map<String,object>  o=( map<String,object>)JsonToFieldMap.get(key);
                   
                    if(o.get('displayName')!=null){
                        data=String.valueOf(o.get('displayName')); 
                        
                    }else if(o.get('value')!=null){
                        data=String.valueOf(o.get('value')); 
                        
                    }else if(o.get('name')!=null){
                        data=String.valueOf(o.get('name')); 
                        
                    }else if(o.get('key')!=null){
                        data=String.valueOf(o.get('key')); 
                        
                    }
                    
                    if(o.get('child')!=null){
                        data=String.valueOf(o.get('id'));
                        map<String,object>  o1=( map<String,object>)o.get('child');        
                        data+='_child_'+String.valueOf(o1.get('id'));
                        
                    }
                    bb=true;
                    
                }
            }catch(exception e){
                bb=false;
            }
            
            try{
                if(!bb){
                    String o=(String)JsonToFieldMap.get(key);
                    if(o==null){
                        data='';
                    }else{
                       data=o.stripHtmlTags() ;
                    }
                    
                    bb=true;
                    
                }
            }catch(exception e){
                bb=false; 
            }
            try{
                if(!bb){
                    
                    Decimal o=( Decimal)JsonToFieldMap.get(key);
                    data=String.valueof(o);
                    bb=true;
                    
                    
                    
                }
            }catch(exception e){
                bb=false; 
            }
            try{
                if(!bb){                    
                    String jsonss=Json.serialize(JsonToFieldMap.get(key));
                    list<object>  o=( list<object>)json.deserializeUntyped(jsonss);
                    for(Object ss:o){
                        String sss=json.serialize(ss);
                        map<String ,object> obp= (map<String ,object>)json.deserializeUntyped( sss);
                        if(obp.get('id')!=null){
                            data+=String.valueof(obp.get('id'))+',';
                        }else if(obp.get('key')!=null){
                            data+=String.valueOf(obp.get('key'))+','; 
                            
                        }else if(obp.get('value')!=null){
                            data+=String.valueOf(obp.get('value'))+',';
                            
                        }else if(obp.get('name')!=null){
                            data+=String.valueOf(obp.get('name'))+',';
                            
                        }else if(obp.get('displayName')!=null){
                            data+=String.valueOf(obp.get('displayName'))+',';
                            
                        } 
                        
                    }
                    
                    bb=true;
                    
                }
            }catch(exception e){
                bb=false; 
            }
            try{
                if(!bb){                    
                    List<object> o=( List<object>)JsonToFieldMap.get(key);
                    for(object ss:o){
                        data+=String.valueof(ss)+',';
                    }
                    bb=true;
                    
                }
                
            }catch(exception e){
                bb=false;
            }
        }
        
        return data;
    }
    
    public Static String getFieldDataForReporting(String key,map<String, Object>JsonData){
        map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
        
        String data=''; 
        Boolean  bb=false;
        if(key.toLowerCase()=='key'||key.toLowerCase()=='link'){
            if(key.toLowerCase()=='key' && JsonData.get('key')!=null){
                data=String.valueOf(JsonData.get('key'));
            }else if(key.toLowerCase()=='link' &&  JsonData.get('self')!=null){
                data=JiraService.fetchDomain(String.valueOf(JsonData.get('self')))+'/browse/'+JsonData.get('key');
            }
        }else{
            try{
                if(!bb){
                    map<String,object>  o=( map<String,object>)JsonToFieldMap.get(key);    
                    if(o.get('displayName')!=null){
                        data=String.valueOf(o.get('displayName')); 
                        
                    }else if(o.get('value')!=null){
                        data=String.valueOf(o.get('value'));  
                        
                    }else if(o.get('name')!=null){
                        data=String.valueOf(o.get('name')); 
                        
                    }else if(o.get('key')!=null){
                        data=String.valueOf(o.get('key'));
                        
                    }                   
                    if(o.get('child')!=null){
                        data=String.valueOf(o.get('value'));
                        map<String,object>  o1=( map<String,object>)o.get('child');        
                        data+='__'+String.valueOf(o1.get('value'));
                        
                    }
                    bb=true;
                }
            }catch(exception e){
                bb=false;
            }
            
            try{
                if(!bb){
                    String o=(String)JsonToFieldMap.get(key);
                    if(o==null){
                        data='';
                    }else{
                         data=o.stripHtmlTags() ; 	
                    }                    
                    bb=true;
                }
            }catch(exception e){
                bb=false; 
            }
            try{
                if(!bb){                    
                    Decimal o=( Decimal)JsonToFieldMap.get(key);
                    data=String.valueof(o);
                    bb=true;                    
                }
            }catch(exception e){
                bb=false; 
            }
            try{
                if(!bb){                    
                    String jsonss=Json.serialize(JsonToFieldMap.get(key));                    
                    list<object>  o=( list<object>)json.deserializeUntyped(jsonss);                    
                    for(Object ss:o){
                        String sss=json.serialize(ss);
                        map<String ,object> obp= (map<String ,object>)json.deserializeUntyped( sss);
                        if(obp.containsKey('name') && obp.get('name')!= null){
                            data+=String.valueof(obp.get('name'))+',';
                        }else if(obp.containsKey('value') && obp.get('value')!= null){
                            data+=String.valueof(obp.get('value'))+',';
                        }else if(obp.containsKey('displayName') && obp.get('displayName')!= null){
                            data+=String.valueof(obp.get('displayName'))+',';
                        }
                        else if(obp.containsKey('issuelinks') && obp.get('issuelinks')!= null){
                            
                        }                        
                    }
                    data = data.removeEnd(',');
                    bb=true;
                }
            }catch(exception e){
                bb=false; 
            }
            try{
                if(!bb){                    
                    List<object>  o=( List<object>)JsonToFieldMap.get(key);                    
                    for(object ss:o){
                        data+=String.valueof(ss)+',';
                    }
                    bb=true;
                }                
            }catch(exception e){
                bb=false;
            }
        }
        return data;
    }
    public Static Map<String,List<LinkedIssues>> getIssueLinkData(String key,map<String, Object>JsonData){
        
        String header=''; 
        String data=''; 
        Boolean  bb=false;
        map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
        
        Map<String,List<LinkedIssues>> MapToReturn = New Map<String,List<LinkedIssues>>();
        try{
            if(!bb){
                String jsonss=Json.serialize(JsonToFieldMap.get(key));
                list<object>  o=( list<object>)json.deserializeUntyped(jsonss);    
                
                for(Object ss:o){
                    List<LinkedIssues> LiList = New List<LinkedIssues>();
                    String sss=json.serialize(ss);
                    map<String ,object> obp= (map<String ,object>)json.deserializeUntyped(sss);
                    String RelationKey = Json.serialize(obp.get('id'));
                    /* Get the type of the linked Issues type*/
                    String Type = Json.serialize(obp.get('type'));
                    map<string,object> typeMap = (Map<String,object>)json.deserializeUntyped(Type);
                    
                    if(obp.containsKey('inwardIssue') && (obp.get('inwardIssue')!=null))
                        header = String.ValueOf(typeMap.get('inward'));
                    
                    else if(obp.containsKey('outwardIssue') && (obp.get('outwardIssue')!=null))
                        header = String.ValueOf(typeMap.get('outward'));
                    
                    /* get the linked issues data */
                    String Issuedata = '';
                    if(obp.containsKey('inwardIssue'))
                        Issuedata = Json.serialize(obp.get('inwardIssue'));
                    else if(obp.containsKey('outwardIssue'))
                        Issuedata = Json.serialize(obp.get('outwardIssue'));
                    
                    map<String ,object> finalObj= (map<String ,object>)json.deserializeUntyped(Issuedata);
                    //data = String.ValueOf(finalObj.get('key'));
                    String Status = getFieldDataForReporting('status' , finalObj);
                    String summary = getFieldDataForReporting('summary' , finalObj);
                    if(summary.length() > 20)
                        summary = summary.Substring(0,15) + '...';
                    LinkedIssues LI = New LinkedIssues();
                    Li.Id = String.ValueOf(obp.get('id'));
                    Li.Status = Status;
                    Li.summary = summary;
                    Li.key = String.ValueOf(finalObj.get('key'));
                    LiList.add(Li);
                    
                    data = String.ValueOf(finalObj.get('key')) + ' (' + Status + ')';
                    if(!MapToReturn.containsKey(header)){
                        MapToReturn.put(header , LiList);
                    }
                    else{
                        MapToReturn.get(header).add(Li);
                    }
                }
                if(!MapToReturn.isEmpty()){
                    //data = data.removeEnd(',');
                    bb = true;
                }
            }
        }catch(exception e){
            bb=false;
        }
        
        return MapToReturn;
    }
    
    public class LinkedIssues{
        public string Id{get;set;}
        public string Key{get;set;}
        public string Status{get;set;}
        public string Summary{get;set;}
        
        public LinkedIssues(){}
    }
}