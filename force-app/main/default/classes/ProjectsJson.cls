global  class ProjectsJson{
    public String id;
    public String key;
    public String name;
    public List<IssueType> issuetypes;
   
           
    global class IssueType{
        public String id;
        public Boolean subtask;
        public String name;
        public map<String,FieldJson> fields;
    }    
    
    global class FieldMeta{
        public  String Issuetype;
        public  String ReqInIssuetype;
        public  String Fieldname;
        public  FieldJson Fieldjsondata;
        
    }
    
    global class FieldJson {
        public Boolean required;
        public ProjectsJson.schemaobj schema;
        public string name;  
        public string key; 
        public list<ProjectsJson.allowedValuesobj> allowedValues= new list<ProjectsJson.allowedValuesobj>() ;
        
        public FieldJson(){
            allowedValues =new list<ProjectsJson.allowedValuesobj>();
            schema= new ProjectsJson.schemaobj();
        }
        
        
    }
    global class schemaobj{
        public string type;  
        public string items;
        public string custom;
    }
    global class allowedValuesobj{
        public string id;  
        public string name;
        public string value;
        public list<ProjectsJson.children> children= new list<ProjectsJson.children>() ;
    }
    
    global class children{
         public string id;
         public string value;
    }
     
   
}