import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;

public class List{

    public static void main(String[] args){
        assembleCandidates();
    }
    public static void assembleCandidates(){
        ArrayList<String> wordList = createWordList();
        ArrayList<String> tldArrayList = createTLDArrayList();
        ArrayList<String> candidates = new ArrayList<>();

        for (String word :
                wordList) {
            for (String tld :
                    tldArrayList) {
                if(word.endsWith(tld)){
                    candidates.add(word);
                    break;
                }
            }
        }

        System.out.println(candidates.size());

        candidates = testIfValidTLD(candidates);
        writeResults(candidates);


        
    }
    public static ArrayList<String> createWordList(){
        ArrayList<String> wordList = new ArrayList<>();
        try {
            BufferedReader wordListReader = new BufferedReader(new FileReader("wordsrev.txt"));
            String line = wordListReader.readLine();

            while (line != null) {
                line = line.replaceAll("\\W","");
                if(line.length()>=6 && !line.contains("'")){
                    line = line.toLowerCase();
                    if(!wordList.contains(line)){
                        wordList.add(line);
                    }
                }
                line = wordListReader.readLine();
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
        return wordList;
    }
    
    public static ArrayList<String> createTLDArrayList(){
        ArrayList<String> tldArrayList = new ArrayList<>();
        try {
            BufferedReader TLDListReader = new BufferedReader(new FileReader("tlds-alpha-by-domain.txt"));
            String line = TLDListReader.readLine();

            while (line != null) {
                if(line.length()==2){
                    line = line.toLowerCase();
                    tldArrayList.add(line);
                }
                line = TLDListReader.readLine();
            }

        } catch (IOException e) {
            e.printStackTrace();
        } 
        return tldArrayList;
    }



    private static void writeResults(ArrayList candidates){
        try{
            PrintWriter writer = new PrintWriter("output.txt", "UTF-8");
            candidates.forEach(writer::println);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static ArrayList<String> testIfValidTLD(ArrayList<String> candidates){
        ArrayList<String> nonExistingCandidates = new ArrayList<>();

            for (String candidate :
                    candidates) {
                candidate = new StringBuilder(candidate).insert(candidate.length()-2, ".").toString();
                try {
                InetAddress inetAddress = InetAddress.getByName(candidate);}
                catch (UnknownHostException e) {
                        nonExistingCandidates.add(candidate);
                    System.out.println(candidate);
                }

        }
        return nonExistingCandidates;
    }
}
