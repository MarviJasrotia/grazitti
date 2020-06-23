/***
    This Class fetch the genric objects Name Based on its ID
****/

global with Sharing Class fetchGenericObjectInfo{
    
    global String sobjectName{get;set;}
    global ID sobjectID{get;set;}
    
    global fetchGenericObjectInfo(ApexPages.StandardController stndController){
        
        sobjectID=ApexPages.CurrentPage().getParameters().get('ID');
        
        if(sobjectID!=NULL ){
           sObjectName=sObjectID.getSobjectType().getDescribe().getName();
           
           if (sObjectName.contains('Grz_Sf__')) {
                    sObjectName =sObjectName.remove('Grz_Sf__');
           } 
           if(sObjectName.containsIgnoreCase('__c')){
               sObjectName = sObjectName.remove('__c');
           }
            if(sObjectName.contains('__'))sObjectName=sObjectName.substring(sObjectName.indexof('__')+2,sObjectName.length() );
            

        }  
        String OrgNameSpace =[SELECT Id, NamespacePrefix  FROM Organization LIMIT 1].NamespacePrefix;
       
        if(OrgNameSpace!=null && OrgNameSpace!=''){
           sObjectName= OrgNameSpace+'__'+sObjectName;
        }
        
    }
}