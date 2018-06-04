from sklearn import tree
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
        self.tree_clf = tree.DecisionTreeClassifier()
        self.longest_word = 0

    def find_longest_word(self, words):
        sortedwords = sorted(words, key=len)
        self.longest_word = len(sortedwords[-1])

    def preper_training_data(self):
        text = self.input_data
        words = self.split_string_to_words(text)
        self.find_longest_word(words)
        self.is_training_data_eq_supervisor(words)
        self.training_data = self.convert_to_ascii(words)

    def train_clf_tree(self):
        self.tree_clf.fit(self.training_data, self.supervisor)


    def train_xxx(self):
        pass

    def preper_test_data(self):
        text = self.test_data
        words = self.split_string_to_words(text)
        self.test_data = self.convert_to_ascii(words)

    def test_model(self):
        """take diffrent already trained models"""
        self.preper_test_data()
        if self.tree_clf.predict(self.test_data):
            print "to jest test"
        else:
            print "to NIE jest test"




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
        print len(self.supervisor), len(words)
        if len(self.supervisor) != len(words):
            print len(self.supervisor), len(words)
            raise Exception('blad')



def main():


    test_names = '\"Automated_eNB_Capacity__Traffic_profile_FSMF_normal__BW-5\", \'Automated_eNB_Capacity__Traffic_profile_FSMF_normal_MME_outage__BW-10\', \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal__BW-10\", \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal__BW-15\", \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal_no_syslogging__BW-20\",	 \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal__BW-20\", \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal_long__BW-20\",  \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal_LTE1042__BW-20\", \"Automated_eNB_Capacity__Traffic_profile_FSMF_high_long__BW-20\", \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal_with_cell_trace__BW-20\", \"Automated_eNB_Capacity__Traffic_profile_FSMF_high__BW-20\", \"BTS_Capacity_U-Plane_Burst_Load_enabled\", \"BTS_Capacity_U-Plane_Burst_Load_disabled\",  \"BTS_Capacity_HO_Burst_Load_enabled\",  \"BTS_Capacity_HO_Burst_Load_disabled\",   \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal_with_max_number_of_LNRELs__BW-20\",  \"Automated_eNB_Capacity__Traffic_profile_FSMF_normal_with_max_number_of_LNRELs__BW-20_X2_update\",  \"Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_without_SDL\",  \"Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_with_SDL\",  \"Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_without_SDL_and_cell_trace\",  \"Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_with_SDL_and_cell_trace\",   \"Automated_eNB_LTE1771_Dual_UPlane_Traffic_Profile_IPv4\",  \"Automated_eNB_LTE1771_Dual_UPlane_Performace_Handovers\",  \"Automated_eNB_LTE1771_Dual_UPlane_Traffic_Profile_IPv4_single_interface\",  \"Automated_eNB_LTE1771_Dual_UPlane_Traffic_Profile_IPv6\",  \"BTS_Capacity_LTE1788_Automatic_Access_Class_Barring_-_Basic_scenario_-_ACB_start\",   \'Dual_UPlane_Call_Model_2cables_IPv4\',  \'Dual_UPlane_Handovers_2cables_IPv4\',  \'Dual_UPlane_Call_Model_2cables_IPv6\',  \'Dual_UPlane_Call_Model_1cable_IPv4_single\',  \'Traffic_profile_FSMF_normal__BW-5\',  \'Traffic_profile_FSMF_normal__BW-10\',  \'Traffic_profile_FSMF_normal_MME_outage__BW-10\',                                                        \'Traffic_profile_FSMF_normal__BW-15\',  \'Traffic_profile_FSMF_normal__BW-20\',  \'Traffic_profile_FSMF_normal_no_syslogging__BW-20\',                                                 \'Traffic_profile_FSMF_normal_with_cell_trace__BW-20\',                                                  \'Traffic_profile_FSMF_normal_LTE1042__BW-20\',                                                        \'Traffic_profile_FSMF_high__BW-20\',                                                                      \'Traffic_profile_FSMF_normal_long__BW-20\',  \'Traffic_profile_FSMF_high_long__BW-20\',  \'Traffic_profile_FSMF_normal_with_max_number_of_LNRELs__BW-20\',                                                                          \'Traffic_profile_FSMF_extreme_high_intraENB_HO_ACB\',                                                  \'BTS_Capacity_SR_Burst_Load_OVL_control_enabled\',  \'BTS_Capacity_SR_Burst_Load_OVL_control_disabled\',  \'BTS_Capacity_HO_Burst_Load_OVL_control_enabled\',  \'BTS_Capacity_HO_Burst_Load_OVL_control_disabled\',  \'Traffic_profile_FSMF_extreme_high__BW-20\',  \'Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_without_SDL\',                                 \'Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_with_SDL\',                                    \'Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_without_SDL_and_cell_trace\',                  \'Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_with_SDL_and_cell_trace\',                     \'Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_without_SDL_and_cell_trace\',  \'Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_with_SDL_and_cell_trace\',  \'Traffic_profile_FSMF_extreme_high_with_SDL__BW-20_short\',  \'Traffic_profile_FSMF_extreme_high_intraENB_HO_ACB_short\',  \'Traffic_profile_FSMF_normal__BW-20_new\', '
    tab_test_names = test_names.split()
    new_data = ''
    with open('tests_names_001.txt', 'r') as f:
        for line in f:
            new_data += line
    tab_new_data = new_data.split()
    new_data += ' '

    new_data_supervosor = [1] * len(tab_new_data)
    test_name_supervosor = [1] * len(tab_test_names)


    other_words = ''
    with open("other_names.txt", 'r') as f:
        for line in f:
            other_words += line

    ranadom_words = other_words
    ranadom_words_tab = ranadom_words.split()


    ranadom_words_supervisor = [0] * len(ranadom_words_tab)



    text = 'to sa dane testowe, ktore bede zamienione na slowa a pozniej na znaki23 hkjhdsa Automated_eNB__Capacity_RRC_Paging__FSMF_BW-10 Automated_eNB_Capacity__Throughput_DL_UEs_from_50_to_max720_FSMF__BW-5_10_15 Automated_eNB_Capacity__Intra_eNB_handover_performance_with_FSMF_shared_BB_pool__BW Automated_eNB_Capacity__Actively_scheduled_users_full_DL_UDP_with_FSMF_shared_BB_pool__BW-5__UE-1260 '
    # text = 'take e tttt rewq dfgh yhpt cftyu'
    supervisor = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1]

    text = test_names + ' ' + new_data + ranadom_words
    supervisor = test_name_supervosor + new_data_supervosor +ranadom_words_supervisor


    tree_test =  Test_name_recognizer(text, supervisor)
    tree_test.preper_training_data()
    tree_test.train_clf_tree()

    tree_test.test_data = '\"Automated_eNB_Capacity__CPlane_overload_low_traffic_FSMF_with_SDL_pola\"' #dodac brakujace zera!!
    tree_test.test_data = '\"kot,\"'
    #tree_test.test_data = '#'
    tree_test.test_model()









if __name__== "__main__":
    main()


