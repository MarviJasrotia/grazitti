public  class Projects{
    
    
    public class Fieldmeta{
        public  String Issuetype;
        public  String ReqInIssuetype;
        public  String Fieldname;
        public  FieldJson Fieldjsondata;
        
    }
    
    public class FieldJson {
        public Boolean required;
        public Projects.schemaobj schema;
        public string name;  
        public string key; 
      //  public string hasDefaultValue; 
       // public list<String> operations;
        //public list<Projects.allowedValuesobj> allowedValues= new list<Projects.allowedValuesobj>() ;
        
        public FieldJson(){
         //   allowedValues =new list<Projects.allowedValuesobj>();
           // operations=new list<string>();
            schema= new Projects.schemaobj();
        }
        
        
    }
    public class schemaobj{
        public string type;  
        public string items;
        public string custom;
    }
   /* public class allowedValuesobj{
        public string self;  
        public string id; 
        public string description;  
        public string iconUrl;
        public string name;
        public boolean released;
        public string subtask;
        public string avatarId;
        public string value;
        public list<Projects.children> children= new list<Projects.children>() ;
    }
    
    public class children{
         public string id;
         public string value;
    }
     */
   
}