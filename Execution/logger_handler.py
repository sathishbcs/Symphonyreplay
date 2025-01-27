"""
Handles logging functionality for the test management modules
"""
import logging
import os


LOGGER_OBJECT = None


def setup(log_name="Log"):
    """
    Sets up logging for robot framework generation
    """
    global LOGGER_OBJECT
    if LOGGER_OBJECT:
        return LOGGER_OBJECT
    logger = logging.getLogger(log_name)
    logger.setLevel(logging.INFO)
    # create file handler which logs even debug messages
    folder_location = os.path.dirname(os.path.abspath(__file__))
    file_path = os.sep.join([folder_location, 'Robot_Execution.log'])
    file_handler = logging.FileHandler(file_path)
    file_handler.setLevel(logging.NOTSET)
    # create console handler with a higher log level
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(funcName)s '
                                  '- %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)
    # add the handlers to the logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    LOGGER_OBJECT = logger
    return LOGGER_OBJECT
