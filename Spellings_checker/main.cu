/*
* Calculating the Levenshtein distance between two strings
* This is used to find possible substitutions and spelling mistakes
* Author: Dries Nuttin
*/

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <limits>

using namespace std;

int levenshtein(const std::string &s1, int string_length1, const std::string &s2, int string_length2);
void findClosestWords(const std::string &userInput, const std::string &dictionaryFilePath);

int main(int argc, char *argv[])
{
    std::string userInput;
    cout << "Enter a word: ";
    cin >> userInput;
    __managed__ vector<std::string> dictionary;
    std::string word;
    ifstream dictionaryFile(argv[1]);

    if (!dictionaryFile.is_open()) {
        cerr << "Failed to open dictionary.txt" << endl;
        return 1;
    }

    ifstream dictionaryFile(argv[1]);

    while (getline(dictionaryFile, word)){
        dictionary.push_back(word);
    }

    findClosestWords<<<1, 10>>>(userInput, dictionary);
    cudaDeviceSynchronize();
    dictionaryFile.close();

    return 0;
}

__global__ void findClosestWords(const std::string &userInput, vector<std::string> Dictionary)
{
    
    
    std::string word;
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    
    if (tid >= Dictionary.size()) {
        return;
    }
    vector<string> closestWords;
    int minDistance = numeric_limits<int>::max();
        
    Dictionary[tid] = word;
     
        int distance = levenshtein(userInput, userInput.length(), word, word.length());
        if(distance == 0){
            std::cout << endl << "This word is spelled correctly"<< endl;
            return;
        }
        else if (distance < minDistance) {
            minDistance = distance;
            closestWords.clear();
            closestWords.push_back(word);
        } else if (distance == minDistance) {
            closestWords.push_back(word);
        }
    

    std::cout << endl << "Closest word(s) to '" << userInput << "' with a distance of " << minDistance << ":" << endl;
    for (const auto &closestWord : closestWords) {
        std::cout << closestWord << endl;
    }
    

}

int levenshtein(const std::string &s1, int string_length1, const std::string &s2, int string_length2)
{
    int sub, insert, del;
    // Check if the string is empty or not, if it is empty it would require the length of the other string as the amount of deletions to become the first string.
    if (string_length1 == 0)
    {
        return string_length2;
    }
    if (string_length2 == 0)
    {
        return string_length1;
    }

    // If the last letter is the same for both strings, we can skip this as there is no operation needed
    if (s1[string_length1 - 1] == s2[string_length2 - 1])
    {
        return levenshtein(s1, string_length1 - 1, s2, string_length2 - 1);
    }

    // Going through the string and checking if a substitution, an insertion, or a deletion needs to take place.
    sub = levenshtein(s1, string_length1 - 1, s2, string_length2 - 1);
    insert = levenshtein(s1, string_length1, s2, string_length2 - 1);
    del = levenshtein(s1, string_length1 - 1, s2, string_length2);

    // Check which method is superior
    if (sub > insert)
    {
        sub = insert;
    }
    if (sub > del)
    {
        sub = del;
    }

    // Return plus 1 to account for the last action performed
    return sub + 1;
}
