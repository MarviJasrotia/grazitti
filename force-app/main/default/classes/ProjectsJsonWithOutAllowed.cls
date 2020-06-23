public class ProjectsJsonWithOutAllowed {
    //Created on 09-07-2019
    public String id;
    public String key;
    public String name;
    public List<IssueType> issuetypes;
    
    
    public class IssueType{
        public String id;
        public Boolean subtask;
        public String name;
        public map<String,FieldJson> fields;
    }    
    
    public class FieldMeta{
        public  String Issuetype;
        public  String ReqInIssuetype;
        public  String Fieldname;
        public  FieldJson Fieldjsondata;
        
    }
    
    public class FieldJson {
        public Boolean required;
        public ProjectsJsonWithOutAllowed.schemaobj schema;
        public string name;  
        public string key; 
        
        public FieldJson(){
            schema= new ProjectsJsonWithOutAllowed.schemaobj();
        }
        
        
    }
    public class schemaobj{
        public string type;  
        public string items;
        public string custom;
    }
}