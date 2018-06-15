from AI_recognize_test import Test_name_recognizer, Training_data
import re
from shutil import copyfile, rmtree, move
import os, errno, glob
import pickle
# import cPickle as pickle

class Conf_finder():
    def __init__(self, tests_names, desire_conf_unit='-SCENARIO_NAME', test_info_file='tcs_def_LMTS.rtv'):
        self.tests_names = tests_names
        self.test_info_file = test_info_file
        self.test_and_conf = []
        self.desire_conf_unit = desire_conf_unit
        self.start_finding()

    def start_finding(self):
        file_content = self.open_test_info_file()
        impure_test_and_conf = self.match_test_and_conf(file_content)
        self.get_pure_conf_name(impure_test_and_conf)


    def open_test_info_file(self):
        file_content = []
        with open(self.test_info_file, 'r') as f:
            for line in f:
                file_content.append(line)
        return file_content

    def match_test_and_conf(self, file_content):
        # todo obsluzyc testy ktorych poczatek nazwy jest taki sam , akoncowka inna
        # todo obsluzyc blad  sytuacje , kiedy nie znalazlo testu, lub komponentu
        # todo obsluzyc nazwy testow gdzie wykryto [ [] ] itp
        # testowe = 'perl'#'Automated_eNB_Capacity__Throughput_DL_UEs_from_50_to_1500_FSMF_FBBx_BW-20'
        test_and_configuration = []
        for test in self.tests_names:
            test_pattern = r'-TC =>.*'+test
            found = False
            for index, line in enumerate(file_content):
                if found and re.findall(test_pattern, line):
                    print " string {} is not test name".format(test)
                    break
                elif found and re.findall(self.desire_conf_unit, line):
                    if '$' in line:
                        line = self.get_conf_form_variable(index, file_content)
                        pass
                    test_and_configuration.append((test, line))
                    break
                elif re.findall(test_pattern, line):
                    found = True
        return test_and_configuration

    def get_conf_form_variable(self, index, file_content):
        file_content = file_content[:index]
        file_content = file_content[::-1]
        for line in file_content:
            if "$iphy_egate_config_file =" in line:
                return line






    def get_pure_conf_name(self, test_and_conf):
        for pair in test_and_conf:
            character_index = [index for index, ch in enumerate(pair[1]) if ch == "'" or ch == '"']
            foo = pair[1]
            conf_pure_name = foo[character_index[0]+1:character_index[1]]
            self.test_and_conf.append((pair[0], conf_pure_name))
        return self.test_and_conf


class Cleaner():
    def __init__(self, test_and_conf, conf_dir='./FSMr4-FDD-168/'):
        self.test_and_conf = test_and_conf
        self.conf_dir = conf_dir

    def start_celeaning(self):
        searched_dir = self.conf_dir
        os.chdir(searched_dir)
        self.move_selected_files_to_temp()
        self.copy_old_files_to_old()
        self.remove_tmp()

    def move_selected_files_to_temp(self):
        if not os.path.exists('./temp'):
            os.mkdir('./temp')
        for test, conf in self.test_and_conf:
            print "processing ",conf, 'for test ', test
            try:
                move(conf, './temp/'+conf)
            except:
                print "nie ma {}".format(conf)

    def copy_old_files_to_old(self):
        file_pattern = r'.+\.[a-zA-Z]+'
        if not os.path.exists('./old'):
            os.mkdir('./old')
        for file in glob.glob("*"):
            if re.search(file_pattern, file):
                move(file, './old/'+file)

    def remove_tmp(self):
        os.chdir("./temp/")
        for file in glob.glob("*"):
            move(file, '../'+file)
        os.chdir("../")
        rmtree('./temp/')


def main():

    with open('classifier.p', 'rb') as f:
        random_forest = pickle.load(f)
    random_forest.test_data = 'tcs_runs/tcs_run_FSMr4_FDD_TL168.rtv'
    random_forest.test_model()



    # finder = Conf_finder(random_forest.tests_list)
    # for test,conf in  finder.test_and_conf:
    #     print "{} do testu {}".format(conf, test)
    #
    # dict = {test_name: conf for ( test_name, conf) in finder.test_and_conf}
    # print dict
    # import json
    # with open('jason_scenarios.json', 'w') as f:
    #     json.dump(dict, f)



    finder = Conf_finder(random_forest.tests_list,  desire_conf_unit='-EGATE_CONFIG_FILE', test_info_file='tcs_def_IPHY.rtv')
    cleaner = Cleaner(finder.test_and_conf)
    cleaner.start_cleaning()





if __name__== "__main__":
    main()




