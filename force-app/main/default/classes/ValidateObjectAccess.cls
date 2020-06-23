public with sharing class ValidateObjectAccess {
  /**
   * Method to check wwather the object and fields are Accessible.
   * @param objectType Api name of the object
   * @param fieldname set of field api names of the same object - objecttype.
   * @return true is object and field are accessable.
   */
    public static PermissionWrapper Accessable(set<String> objectType){
       
        PermissionWrapper perwrap = new PermissionWrapper();
        
        map<String,Schema.SObjectType> sOjectMap = Schema.getGlobalDescribe();
        for(String s:objectType){
           
            Schema.SObjectType so= sOjectMap.get(s);
           
            if(so!=null){
                Sobject newObj =so.newSObject();
                Schema.DescribeSObjectResult result=newObj.getSObjectType().getDescribe();
                
                if(result.isAccessible()){
                    perwrap.objectAccessible.add(s);
                }
                if(result.isCreateable()){
                    perwrap.objectCreateable.add(s);
                }
                if(result.isUpdateable()){
                    perwrap.objectUpdatable.add(s);
                }
                if(result.isDeletable()){
                    perwrap.objectDeletable.add(s);
                }
                Map<String, Schema.SobjectField> fields = newObj.getSObjectType().getDescribe().fields.getMap();
                for(String st:fields.keyset()){
                    
                    if(!fields.get(st).getDescribe().isAccessible()){
                        perwrap.FieldNotAccessible.add(s+'.'+st);
                    } 
                    if(!fields.get(st).getDescribe().isCreateable()){
                        perwrap.FieldNotCreateable.add(s+'.'+st);
                    }  
                    if( !fields.get(st).getDescribe().isUpdateable()){
                        perwrap.FieldNotUpdateable.add(s+'.'+st);
                    }
                    
                }
            }
        }
        return perwrap;
    }
    
  public   class PermissionWrapper{
      public  set<String> objectUpdatable;
      public  set<String> objectAccessible;
     public   set<String> objectDeletable;
     public   set<String> objectCreateable;
     public   set<String> FieldNotAccessible;
     public   set<String> FieldNotCreateable;
     public   set<String> FieldNotUpdateable;
        
        public PermissionWrapper(){
            objectUpdatable= new set<String>();
            objectAccessible= new set<String>();
            objectDeletable= new set<String>();
            objectCreateable= new set<String>();
            FieldNotCreateable=new set<String>();
            FieldNotAccessible= new set<String>();
            FieldNotUpdateable= new set<String>();
            
            
        }
        
    }
}