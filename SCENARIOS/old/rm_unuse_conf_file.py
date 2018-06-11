#TODO wczytac plik z nazwami testow i wybrac testy
#TODO znalesc  tests_name w iphy/lmts_def
#TODO znalesc dany wczesnij typ pliku konfiguracyjnego i zapisac found_file, rozroznic miedzy zmienna a stringiem
#TODO przeniesc pliki ktore nie naleza do zbioru found_file do folderu old
from AI_recognize_test import Test_name_recognizer, Training_data
import re
from shutil import copyfile, rmtree, move
import os, errno, glob

class Conf_test_finder():
    def __init__(self, tests_names, desire_string_conf='-SCENARIO_NAME', test_info_file='tcs_def_LMTS.rtv'):
        self.tests_names = tests_names
        self.test_info_file = test_info_file
        self.test_and_conf = []
        self.open_test_info_file()
        self.desire_string_conf = desire_string_conf



    def open_test_info_file(self):
        file_content = []
        with open(self.test_info_file, 'r') as f:
            for line in f:
                file_content.append(line)
        self.find_tets_index_line(file_content)

    def find_tets_index_line(self,file_content):
        # todo obsluzyc testy ktorych poczatek nazwy jest taki sam , akoncowka inna
        # todo obsluzyc blad  sytuacje , kiedy nie znalazlo testu, lub komponentu
        # todo obsluzyc nazwy testow gdzie wykryto [ [] ] itp
        print "\n\nfind_tets_index_line"
        # testowe = 'perl'#'Automated_eNB_Capacity__Throughput_DL_UEs_from_50_to_1500_FSMF_FBBx_BW-20'
        test_and_configuration = []
        for test in self.tests_names:
            test_pattern = r'-TC =>.*'+test
            found = False
            for line in file_content:
                if found and re.findall('-SCENARIO_NAME', line):
                    # print line
                    test_and_configuration.append((test, line))
                    break
                if re.findall(test_pattern, line):
                    # print line
                    found = True
        # print test_and_configuration
        self.get_pure_conf_name(test_and_configuration)

    def get_pure_conf_name(self, test_and_conf):
        "cala linie z tcd przekszalcic na nazwe configuracji, na podstawie tego co jest w cudzyslowie"
        for pair in test_and_conf:
            character_index = [index for index, ch in enumerate(pair[1]) if ch == "'" or ch == '"']
            foo = pair[1]
            conf_pure_name = foo[character_index[0]+1:character_index[1]]
            self.test_and_conf.append((pair[0], conf_pure_name))
        return self.test_and_conf


class Cleaner():
    def __init__(self, test_and_conf, conf_dir='.'):
        self.test_and_conf = test_and_conf
        self.conf_dir = conf_dir

    def move_selected_files_to_temp(self):
        if not os.path.exists('./temp'):
            os.mkdir('./temp')
        for test, conf in self.test_and_conf:
            print "processing ",conf, 'foor test ', test
            move('./'+conf, './temp/'+conf)
        self.copy_old_files_to_old()
        os.chdir("./temp/")
        for file in glob.glob("*"):
             move(file, '../'+file)
        os.chdir("../")
        rmtree('temp')

    def copy_old_files_to_old(self):
        file_pattern = r'.+\.[a-zA-Z]+'
        if not os.path.exists('./old'):
            os.mkdir('./old')
        os.chdir("./")
        for file in glob.glob("*"):
            if re.search(file_pattern, file):
                move(file, 'old/'+file)




def main():

    # prepare training data
    Call_modes_set = Training_data("train_data_call_models.txt", 1)
    Tests_names001_set = Training_data("tests_names_001.txt", 1)
    Random_words_set = Training_data("other_names.txt", 0)
    train_data_tl226 = Training_data("training_positive_tl226.txt",1)

    training_data = Random_words_set.training_content + Call_modes_set.training_content + Tests_names001_set.training_content + train_data_tl226.training_content
    supervisor = Random_words_set.training_supervisor + Call_modes_set.training_supervisor + Tests_names001_set.training_supervisor + train_data_tl226.training_supervisor

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
    random_forest.test_data = 'tcs_runs/tcs_run_FSMr3_FDD_TL022.rtv'
    random_forest.test_model()
    # print random_forest.tests_list[0]
    # random_forest.test_data = 'short_test_set.txt'
    # random_forest.test_model()

    finder = Conf_test_finder(random_forest.tests_list)
    cleaner = Cleaner(finder.test_and_conf)
    cleaner.move_selected_files_to_temp()





if __name__== "__main__":
    main()




