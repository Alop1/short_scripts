from sklearn import tree
import os.path
from sklearn.ensemble import RandomForestClassifier
from decimal import Decimal
from sklearn.datasets import make_classification
import numpy as np
import sklearn
import pickle



class Test_name_recognizer():
    def __init__(self, input_data, supervisor):
        self.input_data = input_data
        self.supervisor = supervisor
        self.test_data = ''
        self.training_data = []
        self.clf = tree.DecisionTreeClassifier()
        self.longest_word = 0
        self.positive_test = 0
        self.testing_supervisor = []
        self.tests_list = []

    def train_clf_tree(self):
        self.clf.fit(self.training_data, self.supervisor)

    def train_clf_random_forest(self):
        self.clf = RandomForestClassifier(max_depth=7, random_state=1, verbose=1, bootstrap=True)
        self.clf.fit(self.training_data, self.supervisor)

    def find_longest_word(self, words):
        sortedwords = sorted(words, key=len)
        self.longest_word = len(sortedwords[-1])

    def prepare_training_data(self):
        text = self.input_data
        words = self.split_string_to_words(text)
        words = [word.replace('"', '') for word in words]
        words = [word.replace("'", '') for word in words]
        self.find_longest_word(words)
        self.is_training_data_eq_supervisor(words)
        self.training_data = self.convert_to_ascii(words)

    def prepare_test_data(self):
        text = self.test_data
        self.string_tests_name = self.test_data[:]
        if self.isfile(text):
            words = self.read_file(text)
        else:
            words = self.split_string_to_words(text)
        words = [word.replace('"', '') for word in words]
        words = [word.replace("'", '') for word in words]
        words = [word.replace("#", '') for word in words]
        self.string_tests_name = words[:]
        self.test_data = self.convert_to_ascii(words)


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

    def test_model(self,  pos_or_neg = 0):
        """take any already trained models"""
        self.positive_test = pos_or_neg
        self.prepare_test_data()
        data = []
        data.append(self.test_data)
        predictions_list = map(self.clf.predict, data)
        predictions_list = list(predictions_list[0])
        self.present_data(predictions_list, self.string_tests_name)

    def present_data(self,prediction_list, data):
        print "PREZENTACJA DANYCH "
        # print "red list ", len(prediction_list), "dtat ", len(data)
        for i in xrange(len(prediction_list)):
            print i," slowo ",data[i], "jest testem ", prediction_list[i]
            if prediction_list[i]:
                temp = data[i]
                true_test = temp.replace(",", '')
                self.tests_list.append(true_test)
        self.count_accuracy(prediction_list)

    def count_accuracy(self, preduction_list):
        if self.positive_test:
            correct_prediction = preduction_list.count(1)
        else:
            correct_prediction = preduction_list.count(0)
        print "correct pred {} number of predicted obj {}".format(correct_prediction, len(preduction_list))
        correctness_ratio = Decimal(correct_prediction)/Decimal(len(preduction_list))
        print "#########################################################"
        print "CORRECTNESS RATIO: ", correctness_ratio
        print "#########################################################\n"


    ###########################################

    def isfile(self, text):
        return os.path.isfile(text)

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

    # prepare training data
    Call_modes_set = Training_data("train_data_call_models.txt", 1)
    Tests_names001_set = Training_data("tests_names_001.txt", 1)
    Random_words_set = Training_data("other_names.txt", 0)
    train_data_tl226 = Training_data("training_positive_tl226.txt",1)
    lmts_test_names = Training_data("test_name_lmts_tcsdef.txt", 1)
    lmts_cfg_names = Training_data("commissioning_names_lmts_tcsdef.txt", 0)

    training_data = lmts_cfg_names.training_content + Random_words_set.training_content + lmts_test_names.training_content + Call_modes_set.training_content + Tests_names001_set.training_content + train_data_tl226.training_content
    supervisor = lmts_cfg_names.training_supervisor + Random_words_set.training_supervisor + lmts_test_names.training_supervisor + Call_modes_set.training_supervisor + Tests_names001_set.training_supervisor + train_data_tl226.training_supervisor

    # prepare decision tree model
    # tree_test = Test_name_recognizer(training_data, supervisor)
    # tree_test.prepare_training_data()
    # tree_test.train_clf_tree()

    # TESTOWANIE MODELU
    # tree_test.test_data = '"Airscale_BTS_Capacity_Static_Users_840UEs_3cell_4x4MIMO_IRC_24Mbps_UL_111Mbps_DL_20MHz'
    # tree_test.test_model()
    # tree_test.test_data = '"eNB_Capacity_PTT_user_amount_QCI66_BW-5__UE-120",'
    # tree_test.test_model()
    # tree_test.test_data = 'tests_positive.txt'
    # tree_test.test_model()
    # tree_test.test_data = '"Airscale_BTS_Throughput_200UEs_3cell_4x4MIMO_IRC_206_245Mbps_DL_TM4_15_20MHz,"'
    # tree_test.test_model()
    # tree_test.test_data = '\'Airscale_BTS_UE_per_TTI_DL_4cell_4x4MIMO_MRC_20MHz,\''
    # tree_test.test_model()
    # tree_test.test_data = 'tests_negative.txt'
    # tree_test.test_model()

    # prepare RF model
    random_forest = Test_name_recognizer(training_data, supervisor)
    random_forest.prepare_training_data()
    random_forest.train_clf_random_forest()

    # test RF model
    '''
    random_forest.test_data = '"Airscale_BTS_Capacity_Static_Users_840UEs_3cell_4x4MIMO_IRC_24Mbps_UL_111Mbps_DL_20MHz'
    random_forest.test_model()
    random_forest.test_data = '\'Airscale_BTS_UE_per_TTI_DL_4cell_4x4MIMO_MRC_20MHz,\''
    random_forest.test_model()
    random_forest.test_data = 'tests_positive_168.txt'
    random_forest.test_model()
    #### print random_forest.clf.predict_proba(random_forest.test_data)
    random_forest.test_data = '\'Airscale_BTS_UE_per_TTI_DL_4cell_4x4MIMO_MRC_20MHz,\''
    random_forest.test_model()
    #### print random_forest.clf.predict_proba(random_forest.test_data)
    # random_forest.test_data = 'tests_negative.txt'
    # random_forest.test_model()
    '''
    # random_forest.test_data = 'tcs_runs/tcs_run_FSMr3_FDD_TL183_dawid.rtv'
    # random_forest.test_model()
    # random_forest.tests_list

    # random_forest.test_data = '\'Airscale_BTS_UE_per_TTI_DL_4cell_4x4MIMO_MRC_20MHz,\''
    # random_forest.test_model()
    # random_forest.test_data = 'tests_positive_168.txt'
    # random_forest.test_model()
    #
    # random_forest.test_data = 'tests_negative.txt'
    # random_forest.test_model()
    # random_forest.test_data = 'tcs_runs/tcs_run_FSMr4_FDD_TL153_kordula_TL1069.rtv'
    # random_forest.test_model(True)
    random_forest.test_data = 'tcs_runs/tcs_run_FSMr4_FDD_TL168.rtv'
    random_forest.test_model()
    print random_forest.tests_list
    with open('classifier.p', 'wb') as f:
        pickle.dump(random_forest, f)


if __name__== "__main__":
    main()


