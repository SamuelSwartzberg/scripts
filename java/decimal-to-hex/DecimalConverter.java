

public final class DecimalConverter {



    public static String toHexadecimalString(int decimalNumber){

        int[] hexValueArray = convertToHexValueArray(decimalNumber);
        String hexNumber = convertHexValueArrayToString(hexValueArray);
        return hexNumber;}

    private static int[] convertToHexValueArray (int decimalNumber){

        final int MAX_HEX_LENGTH = getMaxHexLengthOf(decimalNumber);
        int[] hexValuesArray = new int[MAX_HEX_LENGTH];

        //assemble Hex Array From Decimal Number

        for (int i = MAX_HEX_LENGTH-1; i >= 0 ; i--) {
            int ithDigitValue = (int) Math.pow(16,i);
            hexValuesArray[i] = decimalNumber/ithDigitValue;
            decimalNumber = decimalNumber % ithDigitValue;}

        return reverseIntArray(hexValuesArray); //reverse array here
    }

    private static int getMaxHexLengthOf(int decimalNumber){
        return (int) Math.ceil(Math.log(decimalNumber)/Math.log(16));}

    private static String convertHexValueArrayToString(int [] hexValueArray){
        char[] hexCharArray = new char[hexValueArray.length];
        for (int i = 0; i < hexValueArray.length; i++) {
            hexCharArray[i] = toHexadecimalChar(hexValueArray[i]);}

        String hexNumber = "0x" + strJoin(hexCharArray, "");
        return hexNumber;
    }

    private static char toHexadecimalChar (int hexNumber){
        char[] hexAlphabetArray = "0123456789abcdef".toCharArray();
        return hexAlphabetArray[hexNumber];}

    private static int[] reverseIntArray(int[] array){

        //Source: Stackoverflow

        for(int i = 0; i < array.length / 2; i++) {
            int temp = array[i];
            array[i] = array[array.length - i - 1];
            array[array.length - i - 1] = temp;}
        return array;
    }

    private static String strJoin(char[] aArr, String sSep) {
        StringBuilder sbStr = new StringBuilder();
        for (int i = 0, il = aArr.length; i < il; i++) {
            if (i > 0)
                sbStr.append(sSep);
            sbStr.append(aArr[i]);
        }
        return sbStr.toString();
    }



}
