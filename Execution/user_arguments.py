"""
Defines user arguments which the user passes from command line for driver.py
"""
import argparse
import os
import sys


class UserArguments:
    """
    This class handles user input from passed from command line
    """
    def __init__(self):
        """
        Initializes user arguments class
        """
        current_dir = os.path.dirname(os.path.realpath(__file__))
        self.parent_dir = os.path.abspath(os.path.join(current_dir, os.pardir))

    def get_parser(self, title="Robot Framework Tests Driver"):
        """
        Creates parser object
        :returns parser object to parse
        """
        parser = argparse.ArgumentParser(title)
        parser.add_argument("-s", "--test_server",
                            help="Server on which to run the tests e.g. Dev, Test, QA, Prod",
                            default="Dev", choices=["Dev", "Test", "QA", "Prod"])
        parser.add_argument("-i", "--includeTags", help="Tags to include in tests",
                            default="Regression", nargs='*')
        parser.add_argument("-e", "--excludeTags", help="Tags to exclude in tests",
                            default="", nargs='*')
        parser.add_argument("-o", "--output_dir", help="Output directory for tests",
                            default=os.sep.join(
                                [self.parent_dir, "Output"]))
        parser.add_argument("-l", "--listener", help="Listener for tests", nargs="+",
                            default=[os.sep.join(
                                [self.parent_dir, "Execution", "ResultsListener.py"])])
        parser.add_argument("-v", "--variableFile", help="Variable files for the tests " +
                            "; separated", default=os.sep.join(["Execution", "Access_Data.py"]))
        parser.add_argument("-vars", "--variables", help="Variables list for the test,"
                            "defined in the format varname:value1", nargs="*", default=[])
        parser.add_argument("-b", "--browser", help="Browser on which to run the tests",
                            default="chrome")
        parser.add_argument("-tf", "--test_folder", help="Type of test executed",
                            default="Tests")
        parser.add_argument("-sof", "--skip_on_failure", default="", nargs='*',
                            help="Tags of tests that will be ignored on failed status"
                            )
        parser.add_argument("-cc", "--cleanoutputdir", action='store_true',
                            help="Do not delete output directory before test execution")
        parser.add_argument("-rr", "--rerunFailed", action='store_true',
                            help="Rerun Failed tests once and merge results")
        parser.add_argument("-dr", "--dryrun", action='store_true',
                            help="Executes the tests in dry run to verify no keyword failure")
        parser.add_argument("-xu", "--xunit", action='store_true',
                            help="Create Xunit test results")
        parser.add_argument("-rargs", "--robot_extra_args", help="Arguments not yet available"
                            "through driver script can be passed in a list of quoted arguments",
                            default=[], nargs='*')
        parser.add_argument("-td", "--tidy", action='store_true',
                            help="Tidies up the complete code base in place",
                            default=False)
        parser.add_argument("-st", "--screenshot_stop", action='store_true',
                            help="Stop Screenshot taking if this variable is specified.")
        parser.add_argument("-gl", "--use_global_environment", action='store_true',
                            help="Use global python environment for execution. Can be"
                            " used to enforce using global python build in docker execution")
        parser.add_argument("-xof", "--exit_on_failure", help="Stops test execution on test failure",
                            action='store_true', default=0)

        # Threading variables
        parser.add_argument("-setmax", "--set_max_parallel_threads", type=int,
                            help="Number of max threads to run in parallel.", default=0)
        parser.add_argument("-testsplit", "--test_level_threads_split", action='store_true',
                            help="Split the tests in parallel at test level rather than at suite.",
                            default=0)
        parser.add_argument("-sale", "--salesforce", action='store_true',
                            help="Identify if the test execution is of type salesforce")
        parser.add_argument("-cd", "--cci_debug", action='store_true',
                            help="cci: Drops into pdb, the Python debugger, on an exception")
        parser.add_argument("-cdb", "--cci_debug_before", action='store_true',
                            help="cci: Drops into the Python debugger right before task start")
        parser.add_argument("-cda", "--cci_debug_after", action='store_true',
                            help="cci: Drops into the Python debugger at task completion")
        parser.add_argument("-co", "--connected_org",
                            help="Connected org for the Salesforce execution",
                            default="")

        return parser

    def parse_user_input(self, parser=None, arguments=None):
        """
        Parses input from command line
        :param parser: Parser object or it is created from get_parser function
        :param arguments: Arguments to parse for the parser
        :return:
        """
        if parser is None:
            parser = self.get_parser()
        if arguments is None:
            arguments = sys.argv[1:]
        return parser.parse_args(arguments)
