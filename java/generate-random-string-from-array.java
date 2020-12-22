import java.util.Random;

public class generateRandomFromArray {
    public static void main(String args[]){
        generateRandom();
    }

    private static void generateRandom(){
        String charsIWant = "opüäölopüäölopüäölopüäölopüäölopüäölopüäölopüäölopüäölqwertzuiopüasdfghjklöäyxcvbnm\n\n\n\n";
        int length = 1600;
        char[] values = charsIWant.toCharArray();
        System.out.println(generate(values, length));
    }

    private static String generate(char[] values, int length){
        String result = "";
        Random rngGenerator = new Random();
        for (int i = 0; i < length; i++) {
            int randomIndex = rngGenerator.nextInt(values.length);
            result = result + values[randomIndex];
        }
        return result;
    }


}
