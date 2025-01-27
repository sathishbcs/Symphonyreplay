"""
This file supports execution of Robot tests utlizing parameters passed
by user from command line. It utilises default parameters where no values
are passed by the user.
"""
import os
import subprocess
import sys
import traceback
import logger_handler
import datetime
from setup_options import SetupOptions
from user_arguments import UserArguments
import uuid

class Driver(object):
    """
    Executes Robot Tests
    """
    def __init__(self):
        """
        Initializes Robot Driver class
        """
        self.logger = logger_handler.setup('Robot.Driver')
        self.setup_options = None
        self.args = None

    def parse_arguments(self):
        """
        Parses arguments passed from command line. This can be overridden
        for inheriting class
        """
        self.args = UserArguments().parse_user_input()
        if self.args.variableFile and \
                os.sep.join(["Execution", "Access_Data.py"]) not in self.args.variableFile:
            self.args.variableFile += ";" + os.sep.join(["Execution", "Access_Data.py"])

    def execute_command(self, command):
        """
        Executes the shell command on the running machine.
        """
        self.logger.info("\nExecuting: %s", command)
        if self.setup_options.arg_file_data:
            arg_data = self.setup_options.get_argument_data_excluding_password(
                self.setup_options.arg_file_data)
            self.logger.info("\nArgument File Data:\n%s", arg_data)
        try:
            status = subprocess.call(command, shell=True)
        except subprocess.CalledProcessError:
            status = -1
            self.logger.error(traceback.format_exc())
        return status

    def _build_robot_command_and_execute(self, counter="", rerun=False):
        """
        Builds robot command and executes test
        """
        self.setup_options = SetupOptions(self.args)
        self.setup_options.build_execution_command(counter, rerun)
        status = self.execute_command(self.setup_options.command)
        self.setup_options.delete_options_arguments_file(
            self.setup_options.options_file_tag)
        self.setup_options.command = ""
        return status

    def execute_tests(self, counter=""):
        """
        Performs robot test executions. Different execution command for each of
        the country read from the functional matrix excel.
        Also creates local log.html file in each pabot results directory if it exists
        which will then have the local screenshots embedded.
        """
        status = self._build_robot_command_and_execute(counter)
        if self.args.rerunFailed:
            status = self._build_robot_command_and_execute(counter, True)
        self.update_attached_evidence_paths()
        self.create_pabot_log_files()
        return status

    def update_attached_evidence_paths(self):
        """
        Updates the evidence path in final Output.xml file.
        If the tests are executed through pabot then evidences path are modified
        in Output.xml
        :return:
        """
        if not self.args.salesforce:
            self.setup_options = SetupOptions(self.args)
            #now = datetime.datetime.now()
            #date_time_str = now.strftime("%Y-%m-%d_%H-%M-%S")
            # Append the current date and time to the output directory path
            output_directory_base = os.path.abspath(self.args.output_dir)
            output_directory = os.path.join(output_directory_base)
            output_xml = os.sep.join([output_directory, "Output.xml"])
            self.setup_options.support.update_evidence_paths(output_xml, output_directory)

    def create_pabot_log_files(self):
        """
        Create local log.html files in pabot results directories
        :return:
        """
        if not self.args.salesforce:
            self.setup_options = SetupOptions(self.args)
            python_executable = self.setup_options.get_python_executable()
            output_directory = os.path.abspath(self.args.output_dir)
            self.setup_options.support.create_pabot_local_logfiles(output_directory, python_executable)

    def tidy_up_code(self):
        """
        Tidies up the codebase in place. This function should be called
        before making new code update.
        """
        self.setup_options = SetupOptions(self.args)
        self.setup_options.tidy_command()
        return self.execute_command(self.setup_options.command)

    def robot_tests(self):
        """
        High level execution and combining report functionality
        """
        self.parse_arguments()
        status = 0
        if self.args.tidy:
            status = self.tidy_up_code()
        else:
            status = self.execute_tests()
        return status


if __name__ == "__main__":
    ROBOT_DRIVER = Driver()
    sys.exit(ROBOT_DRIVER.robot_tests())
