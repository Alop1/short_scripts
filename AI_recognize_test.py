from sklearn import tree
import os.path
import numpy as np
import sklearn
#TODO zamienic  testy i commissionigi  na  dane wejsciowe, stworzyc tablice ze slowami(slowa oddziela spacja)-> zamienic kazdy znak w slowie na ascii
#TODO ustawic do tych  supervisora


class Test_name_recognizer():
    def __init__(self, input_data, supervisor):
        # clasifier
        self.input_data = input_data
        self.supervisor = supervisor
        self.test_data = ''
        self.training_data = []
        self.clf = tree.DecisionTreeClassifier()
        self.longest_word = 0
        self.positive_test = True
        self.testing_supervisor = []

    def train_clf_tree(self):
        self.clf.fit(self.training_data, self.supervisor)

    def train_clf_random_forest(self):
        #todo stworzyc rnadom fores super
        #todo wytrenowac go
        pass

    def find_longest_word(self, words):
        sortedwords = sorted(words, key=len)
        self.longest_word = len(sortedwords[-1])

    def preper_training_data(self):
        text = self.input_data
        words = self.split_string_to_words(text)
        self.find_longest_word(words)
        self.is_training_data_eq_supervisor(words)
        self.training_data = self.convert_to_ascii(words)

    def prepare_test_data(self):
        text = self.test_data
        self.string_tests_name = self.test_data[:]
        if self.isfile(text):
            print "to jest plik"
            words = self.read_file(text)
            print words
        else:
            words = self.split_string_to_words(text)
        self.string_tests_name = words[:]
        self.test_data = self.convert_to_ascii(words)

    def isfile(self, text):
        return os.path.isfile(text)

    def read_file(self, text):
        with open(text, 'r') as f:
            plain_text = ''
            for line in f:
                plain_text += line
        words = self.split_string_to_words(plain_text)
        self.create_supervisor(words)
        return words

    def create_supervisor(self, words):
        sortedwords = sorted(words, key=len)
        longest_word = len(sortedwords[-1])
        if self.positive_test == True:
            self.testing_supervisor = [1] * longest_word
        else:
            self.testing_supervisor = [0] * longest_word

    def test_model(self):
        """take diffrent already trained models"""
        self.prepare_test_data()
        data = []
        data.append(self.test_data)
        predictions_list = map(self.clf.predict, data)
        print list(predictions_list[0])
        predictions_list = list(predictions_list[0])
        print predictions_list
        print len(predictions_list)
        print len(data[0])
        data = self.input_data.split()
        self.present_data(predictions_list, self.string_tests_name)

    def present_data(self,prediction_list, data):
        print "PREZENTACJA DANYCH "
        for i in xrange(len(prediction_list)):
            print "slowo ",data[i], "jest testem ", prediction_list[i]

    def count_corretnes(self):
        pass


    ###########################################
    def split_string_to_words(self, text):
        words = text.split()
        return words

    def add_payload_zeros(self,  ascii_word):
        length_difference = self.longest_word - len(ascii_word)
        listofzeros = [0] * length_difference
        ready_ascii_word = ascii_word + listofzeros
        return ready_ascii_word

    def convert_to_ascii(self, words):
        words_by_letter = self.convert_word_to_char_list(words)
        ascii_rep = []
        for word in words_by_letter:
            ascii_word = [ord(l) for l in word]
            if self.is_payload_needed(self.longest_word, ascii_word):
                ascii_word = self.add_payload_zeros(ascii_word)
            ascii_rep.append(ascii_word)
        return ascii_rep

    def is_payload_needed(self, longest_word, ascii_word):
        length_difference = longest_word - len(ascii_word)
        needed = length_difference
        return needed

    def convert_word_to_char_list(self, words):
        return [list(word) for word in words]

    def is_training_data_eq_supervisor(self,words):
        print "#########################################################"
        print "to training you use", len(self.supervisor), len(words)
        print "#########################################################"
        if len(self.supervisor) != len(words):
            print len(self.supervisor), len(words)
            raise Exception('blad')

class Training_data:
    def __init__(self, file_name, pos_or_neg):
        read_file = ''
        with open(file_name, 'r') as f:
            for line in f:
                read_file += line
        tab_read_file = read_file.split()
        read_file += ' '
        self.training_supervisor = [pos_or_neg] * len(tab_read_file)
        self.training_content = read_file



def main():


    Call_modes_set = Training_data("train_data_call_models.txt", 1)
    Tests_names001_set = Training_data("tests_names_001.txt", 1)
    Random_words_set = Training_data("other_names.txt", 0)


    text = 'to sa dane testowe, ktore bede zamienione na slowa a pozniej na znaki23 hkjhdsa Automated_eNB__Capacity_RRC_Paging__FSMF_BW-10 Automated_eNB_Capacity__Throughput_DL_UEs_from_50_to_max720_FSMF__BW-5_10_15 Automated_eNB_Capacity__Intra_eNB_handover_performance_with_FSMF_shared_BB_pool__BW Automated_eNB_Capacity__Actively_scheduled_users_full_DL_UDP_with_FSMF_shared_BB_pool__BW-5__UE-1260 '
    # text = 'take e tttt rewq dfgh yhpt cftyu'
    supervisor = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1]

    text = Call_modes_set.training_content + Tests_names001_set.training_content + Random_words_set.training_content
    supervisor = Call_modes_set.training_supervisor + Tests_names001_set.training_supervisor + Random_words_set.training_supervisor

    tree_test =  Test_name_recognizer(text, supervisor)
    tree_test.preper_training_data()
    tree_test.train_clf_tree()

    #TESTOWANIE MODELU
    tree_test.test_data = '"Airscale_BTS_Capacity_Static_Users_840UEs_3cell_4x4MIMO_IRC_24Mbps_UL_111Mbps_DL_20MHz'
    tree_test.test_model()
    tree_test.test_data = '"eNB_Capacity_PTT_user_amount_QCI66_BW-5__UE-120",'
    tree_test.test_model()
    tree_test.test_data = 'tests_positive.txt'
    tree_test.test_model()
    tree_test.test_data = '"Airscale_BTS_Throughput_200UEs_3cell_4x4MIMO_IRC_206_245Mbps_DL_TM4_15_20MHz,"'
    tree_test.test_model()
    tree_test.test_data = '\'Airscale_BTS_UE_per_TTI_DL_4cell_4x4MIMO_MRC_20MHz,\''
    tree_test.test_model()
    tree_test.test_data = 'tests_negative.txt'
    tree_test.test_model()










if __name__== "__main__":
    main()


