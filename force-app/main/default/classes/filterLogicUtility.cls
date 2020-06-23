public with Sharing class filterLogicUtility{
    public static String updateFilter(String filterLogic,Integer sno){
        try{
            String finalString = '';
            String initialString = filterLogic;
            String notEffectedSNO = '';
            Map<Integer,Integer> mapFilterLogic = new Map<Integer,Integer>();
            Map<Integer,Integer> mapSNoToASCII = new Map<Integer,Integer>();
            mapSNoToASCII.put(1,49);
            mapSNoToASCII.put(2,50);
            mapSNoToASCII.put(3,51);
            mapSNoToASCII.put(4,52);
            mapSNoToASCII.put(5,53);
            Map<Integer,Integer> mapASCIIToSNO = new Map<Integer,Integer>();
            mapASCIIToSNO.put(49,1);
            mapASCIIToSNO.put(50,2);
            mapASCIIToSNO.put(51,3);
            mapASCIIToSNO.put(52,4);
            mapASCIIToSNO.put(53,5);
            if(filterLogic.indexOf('AND')>-1) filterLogic = filterLogic.replaceAll('AND','A');
            if(filterLogic.indexOf('OR')>-1) filterLogic = filterLogic.replaceAll('OR','O'); 
            Set<Integer> allowedNo = new Set<Integer>();
            allowedNo.add(49);
            allowedNo.add(50);
            allowedNo.add(51);
            allowedNo.add(52);
            allowedNo.add(53);
            Integer snoCount = sno;
            for(Integer i=0; i<filterLogic.length(); i++){
                if(allowedNo.contains(filterLogic.charAt(i))){                    
                    if(mapSNoToASCII.get(sno) < filterLogic.charAt(i)) {  mapFilterLogic.put(filterLogic.charAt(i),snoCount); snoCount++;}   
                    else notEffectedSNO += filterLogic.charAt(i);
                }
            }
            for(Integer i=0; i<initialString.length(); i++){
                if(mapFilterLogic.containsKey(initialString.charAt(i))){
                    if(initialString.charAt(i) == 49) {finalString += mapFilterLogic.get(initialString.charAt(i));}    
                    if(initialString.charAt(i) == 50) {finalString += mapFilterLogic.get(initialString.charAt(i));}
                    if(initialString.charAt(i) == 51) {finalString += mapFilterLogic.get(initialString.charAt(i));}
                    if(initialString.charAt(i) == 52) {finalString += mapFilterLogic.get(initialString.charAt(i));}
                    if(initialString.charAt(i) == 53) {finalString += mapFilterLogic.get(initialString.charAt(i));}
                }else{
                    if(initialString.charAt(i) == 49) {finalString += mapASCIIToSNO.get(initialString.charAt(i));}    
                    if(initialString.charAt(i) == 50) {finalString += mapASCIIToSNO.get(initialString.charAt(i));}
                    if(initialString.charAt(i) == 51) {finalString += mapASCIIToSNO.get(initialString.charAt(i));}
                    if(initialString.charAt(i) == 52) {finalString += mapASCIIToSNO.get(initialString.charAt(i));}
                    if(initialString.charAt(i) == 53) {finalString += mapASCIIToSNO.get(initialString.charAt(i));}    
                }
                if(initialString.charAt(i) == 40) finalString += ' ( ';
                if(initialString.charAt(i) == 41) finalString += ' ) ';
                if(initialString.charAt(i) == 65 && initialString.charAt(i+1) == 78 && initialString.charAt(i+2) == 68) finalString += ' AND ';
                
                if(initialString.charAt(i) == 79 && initialString.charAt(i+1) == 82) finalString += ' OR ';
            }
            return finalString;
        }
        catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('filterLogicUtility',null, null, null,null,null, null , null, null, 'updateFilter', Error);
        }   
        return null;     
    }
}