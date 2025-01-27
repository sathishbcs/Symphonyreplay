"""
This file sets up options for the driver script to execute robot tests
"""
import ntpath
import os
import platform
import sys
import yaml
from pip._internal.operations import freeze
import logger_handler
from user_arguments import UserArguments
from support import Support
import datetime
import uuid


class SetupOptions(object):
    """
    Sets up options for user setup from passing options through command line
    """
    def __init__(self, arguments):
        self.args = arguments
        self.arg_file_data = None
        self.command = ""
        if self.args.salesforce:
            self.salesforce_task_dict = {"tasks": {
                "robot": {
                    "options": {
                        "options": {}
                    }
                }
            }}
        self.salesforce_options_dict = {}
        self.arg_separator = os.linesep
        self.user_arguments = UserArguments()
        self.support = Support()
        self.metadata = "_"
        self.logger = logger_handler.setup('Robot.SetupOptions')
        self.options_file_tag = ""
        self.cumulusci_yaml_path = ""

    def add_option_list(self, option, and_separated_list):
        """
        Returns string to add an option with And separated list.

        :param option: Option to add to a command
        :param and_separated_list: List of options to be separated separated by 'AND'
        :type option: string
        :type and_separated_list: list
        :returns:   Addition of commands to be added to the robot commands
        """
        if self.args.salesforce:
            self._add_salesforce_dict_option(option, "Blank", 'AND'.join(and_separated_list))

        value = ""
        if and_separated_list:
            value = " --" + option + " " + 'AND'.join(and_separated_list) + ' ' + \
                   self.arg_separator
        return value

    def add_option(self, option, value=""):
        """
        Returns string to add an option with single value assigned to it.

        :param option: Option to add to a command
        :param value: Value to be set for the option
        :type option: string
        :type value: string
        :returns:   Addition of command to be added to the robot command
        """
        if self.args.salesforce:
            self._add_salesforce_dict_option(option, "Blank", value)
        return " --" + option + " " + value + ' ' + self.arg_separator

    def add_variable(self, variable, value):
        """
        Returns string to add an variable and value assigned to it.

        :param variable: Variable string to add
        :param value: Value to be set for the variable
        :type variable: string
        :type value: string
        :returns:   Variable value example --variable var1:value
        """
        variable_option = variable + ":" + value
        if self.args.salesforce and value:
            if self.salesforce_task_dict["tasks"]["robot"]["options"].get("vars"):
                self.salesforce_task_dict["tasks"]["robot"]["options"]["vars"].append(
                    variable_option)
            else:
                self.salesforce_task_dict["tasks"]["robot"]["options"]["vars"] = [variable_option]
        return " --variable " + variable + ":" + value + ' ' + self.arg_separator

    def add_metadata(self, variable, value):
        """
        Returns string to add an metadata variable and value assigned to it.

        :param variable: Variable string to add
        :param value: Value to be set for the variable
        :type variable: string
        :type value: string
        :returns:   Variable value example --metadata var1:value
        """
        if self.args.salesforce and value:
            self._add_salesforce_dict_option("metadata", variable, value)
        return " --metadata " + variable + ":" + value + ' ' + self.arg_separator

    def _add_salesforce_dict_option(self, option, variable, value):
        """
        Adds option to salesforce option dict
        :param option: Option to add to dict
        :param variable: Variable name to add
        :param value: Value of option
        """
        if not self.salesforce_options_dict.get(option):
            self.salesforce_options_dict[option] = variable + ":" + value
        else:
            self.salesforce_options_dict[option] += self.arg_separator + \
                                                    variable + ":" + value

    def _get_metadata(self):
        """
        Gets the string to be added to names of each output file.

        :return: String to be added to file names in Output
        """
        metadata = ""
        if __name__ != "__main__":
            metadata = "_" + self.metadata
        return metadata

    @staticmethod
    def _add_quotes_to_path(path):
        """
        Adds double quotes to the start and end of path specified.

        :param path: Folder path to add double quotes to
        :type path: string
        :returns:   Double quoted path e.g. '"path"'
        """
        return '"' + path + '"'

    def _get_variable_file(self):
        """
        Adds variable file option to the command line
        """
        option = "variableFile"
        if self.args.salesforce:
            option = "variablefile"

        parent_directory = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        for variable_file in self.args.variableFile.split(";"):
            if not os.path.isabs(variable_file):
                # Assumes that the access data file is part of Execution folder
                variable_file = os.sep.join([parent_directory, variable_file])
            self.command += self.add_option(option, variable_file)

    def _get_variables(self):
        """
        Adds any variables information that is passed from command line
        """
        for variable in self.args.variables:
            key, value = variable.split(":", 1)
            self.command += self.add_variable(key, value)

    def _get_robot_extra_arguments(self):
        """
        Adds any extra arguments passed from the command line to the
        robot execution command
        """
        for extra_parameter in self.args.robot_extra_args:
            self.command += self.add_option(extra_parameter)

    def _get_skip_on_failure_tags(self):
        """
        Adds tests with tags to be executed but excluded from overall test run status
        """
        self.command += self.add_option_list("skiponfailure", self.args.skip_on_failure)

    def _get_exclude_tags(self):
        """
        Adds exclusion tags to the robot command.
        """
        self.command += self.add_option_list("exclude", self.args.excludeTags)

    def _set_test_server(self):
        """
        Adds the type of test server as a variable to the command
        """
        self.command += self.add_variable("test_server", self.args.test_server)
        self.command += self.add_metadata("test_environment", self.args.test_server)

    def _set_screenshot_variable(self):
        """
        Sets the screenshot on/off variable from driver script.
        """
        self.command += self.add_variable(
            "screenshot_taking", str(not self.args.screenshot_stop))

    def _set_exit_on_failure(self):
        """
        Causes test execution to abort if a test fails
        """
        if self.args.exit_on_failure:
            self.command += self.add_option("exitonfailure")

    def _set_pip_dependencies(self):
        """
        Sets up pip dependencies into variable pip_freeze_dependencies
        """
        requirements = freeze.freeze()
        value = ",".join(requirements)
        self.command += self.add_metadata("test_freeze_dependencies", value)

    def _set_executing_system(self):
        """
        Sets up pip dependencies into variable pip_freeze_dependencies
        """
        value = platform.system() + "-" + platform.release()
        self.command += self.add_metadata("test_execution_platform", value)

    def _set_default_browser(self):
        """
        Sets the browser for running qlik based tests on.
        """
        self.command += self.add_variable("browser", self.args.browser)

    def _get_include_tags(self):
        """
        Adds inclusion tags to the robot command.
        """
        if self.args.includeTags and isinstance(self.args.includeTags, str):
            self.args.includeTags = [self.args.includeTags]
        self.command += self.add_option_list("include", self.args.includeTags)

    def _get_listener_file(self):
        """
        Adds listener file option to the robot command.
        """
        if not self.args.dryrun:
            for listener_file in self.args.listener:
                self.command += self.add_option("listener", listener_file)

    def _set_run_name(self, name):
        """
        Sets the name of the test run for the robot command.

        :param name: Name to be set for the test execution
        :type name: string
        """
        self.command += self.add_option("name", name)

    def _set_run_log(self, log_name, tags=""):
        """
        Sets the log name of the test run for the robot command.

        :param log_name: Log name to be set for the test execution
        :param tags: Optional tag names to be added to the log name.
        :type log_name: string
        :type tags: String
        """
        if tags:
            log_name += "_" + tags
        self.command += self.add_option("log", log_name)

    def _add_salesforce_debug_options(self):
        """
        Adds Salesforce debug option if they are passed from command line
        """
        if self.args.salesforce:
            if self.args.cci_debug:
                self.add_option("debug")
            if self.args.cci_debug_before:
                self.add_option("debug-before")
            if self.args.cci_debug_after:
                self.add_option("debug-after")

    def _set_run_report(self, report_name, tags=""):
        """
        Sets the report name of the test run for the robot command.

        :param report_name: Report name to be set for the test execution
        :param tags: Optional tag names to be added to the log name.
        :type report_name: string
        :type tags: String
        """
        if tags:
            report_name += "_" + tags
        self.command += self.add_option("report", report_name)

    def _set_tag(self, tag):
        """
        Sets a tag for all tests running for the test.

        :param tag: Tag to be set for all tests
        :type tag: string
        """
        self.command += self.add_option("settag", tag)

    def _set_options_in_arguments_file(self, counter=""):
        """
        Sets robot options into an argument file with a unique name to prevent overwriting.

        :param counter: Optional string counter to be added to the log name.
        :type counter: String
        """
        # Generate a timestamp or unique identifier
        # timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        # unique_identifier = f"{counter}_{timestamp}" if counter else timestamp
        uid = uuid.uuid4()
        unique_identifier = str(uid)

        file_path = f"Robot_Arguments_{unique_identifier}"
        file_path = os.path.join(self.user_arguments.parent_dir, file_path)
        self.arg_file_data = self.command
        with open(file_path, "w") as file_object:
            file_object.write(self.command)
        quoted_file_path = self._add_quotes_to_path(file_path)
        self.command = f" --argumentfile {quoted_file_path} "

    def _add_xunit_option(self, filename):
        """
        Adds xunit results option.

        :param filename: Name of the file which will be created
        :type filename: string
        """
        if self.args.xunit:
            output_xml = os.sep.join([self.args.output_dir, filename])
            self.command += self.add_option("xunit", output_xml)

    def set_execution_folder(self):
        """
        Sets the final execution folder for the driver script.
        """
        test_folder = os.path.abspath(self.args.test_folder)
        if self.args.salesforce:
            self.salesforce_task_dict["tasks"]["robot"]["options"]["suites"] = test_folder
        quoted_test_folder = self._add_quotes_to_path(test_folder)
        self.command += " " + quoted_test_folder + " "

    def get_rerun_xml(self, xml_run):
        """
        Gets quoted file path for xml rerun path

        :param xml_run: Xml result file generated from previous run
        :type xml_run: string
        :return: Complete path for xml rerun
        """
        path = os.sep.join([self.args.output_dir, xml_run])
        self.command += self.add_option(
            "rerunfailed", path)

    def set_output_folder(self, rerunxml="", tag=""):
        """
        Sets Output folder and logging xml file for the test run.

        :param rerunxml: Rerunning failed tests xml
        :param tag: Thrad tag that needs to be included for test run.
        :type rerunxml: string
        :type tag: String
        """
        self.command += self.add_option(
            "outputdir", self.args.output_dir)
        if not rerunxml:
            filename = "Output.xml"
            if tag:
                filename = "Output_" + tag + ".xml"
            self.command += self.add_option(
                "output", filename)
        else:
            self.command += self.add_option(
                "output", rerunxml)

    def dryrun_execution(self):
        """
        If dryrun option is used then it is set as an option and removed from class variables
        """
        if self.args.dryrun:
            self.command += self.add_option("dryrun")
            self.args.dryrun = False

    def delete_options_arguments_file(self, tags=""):
        """
        Cleans up by deleting an existing robot arguments file

        :param tags: Tags to uniquely identify log report file.
        :type tags: String
        """
        def _delete_file(path):
            "Internal function to delete file"
            self.logger.info("Deleting file: %s", path)
            if os.path.exists(path):
                os.remove(path)

        file_path = "Robot_Arguments" + self._get_metadata() + tags
        file_path = os.sep.join([self.user_arguments.parent_dir, file_path])
        _delete_file(file_path)
        self.arg_file_data = ""

    @staticmethod
    def get_python_executable():
        """
        Returns string equivalent to python executable location.

        :return: Python executable command.
        """
        python_exe = '"' + sys.executable + '"'
        if python_exe == '""':
            python_exe = "python"
        return python_exe

    def _update_list_elements_options_salesforce(self):
        """
        Updates self.salesforce_options_dict for elements which have a newline
        character to be broken into list elements instead
        """
        for option, value in self.salesforce_options_dict.items():
            if "\n" in value:
                list_values = [x.strip() for x in value.split("\n")]
                self.salesforce_options_dict[option] = list_values

    def _update_blank_for_salesforce_options(self):
        """
        Updates self.salesforce_options_dict to remove blank for empty keys
        """
        for option, value in self.salesforce_options_dict.items():
            if value.startswith("Blank:"):
                self.salesforce_options_dict[option] = value.lstrip("Blank:").strip()

    def _update_options_dict_to_task_dict_salesforce(self):
        """
        Updates the self.salesforce_options_dict into self.salesforce_task_dict
        """
        self.salesforce_options_dict = {k: v for k, v in
                                        self.salesforce_options_dict.items() if v}
        self.salesforce_task_dict["tasks"]["robot"]["options"]["options"] = \
            self.salesforce_options_dict

    def _generate_cumulusci_yaml(self):
        """
        Generates yaml file cumulusci.yml for Salesforce execution
        """
        project_dict = {"name": "Salesforce_Automation_Tests",
                        "package": {"name": "Salesforce_Automation_Tests",
                                    "api_version": '48.0'}}
        # api_version is identified at https://eu1.salesforce.com/services/data/
        self.salesforce_task_dict["project"] = project_dict
        self._update_blank_for_salesforce_options()
        self._update_list_elements_options_salesforce()
        self._update_options_dict_to_task_dict_salesforce()
        self._get_cumulusci_yaml_path()
        self.logger.info("cumulusci.yml path: %s", self.cumulusci_yaml_path)
        with open(self.cumulusci_yaml_path, 'w') as file_object:
            yaml.dump(self.salesforce_task_dict, file_object)
        with open(self.cumulusci_yaml_path, 'r') as file_object:
            yaml_data = file_object.read()
            self.logger.info("cumulusci.yml content: \n%s", yaml_data)

    def _get_cumulusci_yaml_path(self):
        """
        Creates cumulusci yaml file path under the folder location where .git folder is.
        If no .git folder then create it at default path location. Also sets class
        variable self.cumulusci_yaml_path
        """
        if self.cumulusci_yaml_path:
            return
        path = os.path.dirname(os.path.abspath(__file__))
        git_found = False
        while True:
            if not path or path == "/":
                break
            if ".git" in os.listdir(path):
                git_found = True
                break
            path = os.path.dirname(path)
        self.cumulusci_yaml_path = "cumulusci.yml"
        if git_found:
            self.cumulusci_yaml_path = os.sep.join([path, self.cumulusci_yaml_path])

    def set_execution_command(self):
        """
        Sets the execution command by adding 'robot ' or 'cci' at the command's start
        """
        if self.args.salesforce:
            self._generate_cumulusci_yaml()
            self.command = "cci task run robot"
            if self.args.connected_org:
                self.command += " --org " + self.args.connected_org
            self.logger.info("\ncommand is : %s", self.command)
        else:
            self._get_updated_execution_command_with_executable()
        self.logger.info("\ncommand is : %s", self.command)

    def _get_updated_execution_command_with_executable(self):
        """
        Updates self.command to build an executable command based on level
        of parallel required for test execution.
        """
        python_executable = self.get_python_executable()
        pabot_executable = self._get_pabot_executable(python_executable)
        if self.args.test_level_threads_split:
            self.command = " --testlevelsplit " + self.command
        if not self.args.set_max_parallel_threads:
            self.command = pabot_executable + " --verbose " + self.command
        else:
            self.command = pabot_executable + " --verbose --processes " + \
                           str(self.args.set_max_parallel_threads) + " " + self.command

    def _get_pabot_executable(self, python_executable):
        """
        Fetches pabot executable string to be included for parallel execution
        :param python_executable: Current python executable path
        :return: Pabot path on the system or virtual environment
        """
        python_executable_dir = ntpath.dirname(python_executable)
        python_executable_dir = python_executable_dir.replace('"', "").replace("'", "")
        pabot_executable_path = pabot_executable_name = "pabot"
        if python_executable_dir and not self.args.use_global_environment:
            pabot_executable_path = os.sep.join([python_executable_dir, pabot_executable_name])
            if sys.platform.startswith("win") and not os.path.exists(pabot_executable_path):
                if not python_executable_dir.endswith("Scripts"):
                    python_executable_dir = os.sep.join([python_executable_dir, "Scripts"])
                pabot_executable_path = os.sep.join([python_executable_dir, pabot_executable_name])
            pabot_executable_path = '"' + pabot_executable_path + '"'
        return pabot_executable_path

    @staticmethod
    def get_argument_data_excluding_password(file_data):
        """
        Fetches the content of argument data without logging the password.

        :param file_data: Data read from arguments file.
        :type file_data: String
        :return: file data without the password line
        """
        parsed_data = ""
        splitter = "\r"
        if file_data.count("\n"):
            splitter = "\n"
        for data in file_data.split(splitter):
            if "ssword:" not in data:
                parsed_data += data.strip() + "\n"
        return parsed_data

    def build_execution_command(self, counter="", rerun=False, ):
        """
        Builds execution command using support options functions
        :return: command to execute robot tests
        """
        parent_dir = self.user_arguments.parent_dir
        os.chdir(parent_dir)
        re_run_xml = ""
        run_report = "Report"
        run_log = "LOG"
        self.command = ""
        self.options_file_tag = counter
        if rerun:
            executed_xml = "Output.xml"
            re_run_xml = "rerun_" + counter + "_" + executed_xml
            self.get_rerun_xml(executed_xml)
            run_log = "rerun_" + "_LOG" + self._get_metadata()
            run_report = "rerun_Report" + self._get_metadata()
            self.options_file_tag = counter + "_rerun"
        self.support.clean_output_directory(self.args.output_dir, self.args.cleanoutputdir)
        self.logger.info("\nExecuting tests from folder: %s",
                         self.args.test_folder)
        self._set_exit_on_failure()
        self._set_test_server()
        self._set_pip_dependencies()
        self._get_include_tags()
        self._get_exclude_tags()
        self._set_default_browser()
        self._get_skip_on_failure_tags()
        self._get_variable_file()
        self._get_variables()
        self._get_robot_extra_arguments()
        self._set_run_log(run_log, counter)
        self._set_run_report(run_report, counter)
        self._get_listener_file()
        self._add_salesforce_debug_options()
        self.dryrun_execution()
        self._set_screenshot_variable()
        self.set_output_folder(re_run_xml, tag=counter)
        self._set_options_in_arguments_file(self.options_file_tag)
        self.set_execution_folder()
        self.set_execution_command()

    def tidy_command(self):
        """
        Tidies up the codebase in place. This function should be called
        before making new code update.
        """
        os.chdir(self.user_arguments.parent_dir)
        python_command = self.get_python_executable()
        if not os.path.isabs(self.args.test_folder):
            self.args.test_folder = os.sep.join(
                [self.user_arguments.parent_dir, self.args.test_folder])
        self.command = python_command + " -m robotidy \"" +\
            self.args.test_folder + "\""
