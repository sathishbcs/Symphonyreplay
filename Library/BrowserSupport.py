"""
Adds functionality to Robot Framework SeleniumLibrary Browser Management.
E.g. from https://github.com/robotframework/SeleniumLibrary/blob/master/
docs/extending/extending/inheritance/InheritSeleniumLibrary.py
"""
import platform
import selenium
from SeleniumLibrary import SeleniumLibrary
from SeleniumLibrary.base import keyword
from SeleniumLibrary.keywords import BrowserManagementKeywords
from selenium import webdriver
from robot.api import logger


class BrowserSupport:
    """
    Overrides functionality defined in Browser Management Keywords
    """
    def __init__(self):
        self.browser = ""
        self.url = ""
        self.added_options = ""
        self.browser_details = None
        super(BrowserSupport, self).__init__()

    def _setup_url_browser(self, *args, **kwargs):
        """
        Sets up browser and url to process open browser
        :param args: Place arguments
        :param kwargs: Keyword arguments dict
        """
        if args:
            self.url = args[0]
        if len(args) > 1:
            self.browser = args[1]
        else:
            self.browser = kwargs.get("browser", self.browser)
            self.url = kwargs.get("url", self.url)

    def open_browser_through_library(self, *args, **kwargs):
        """
        Sets up options for open browser in case tests are run on Linux/Docker
        :param args: Place arguments
        :param kwargs: Keyword arguments dict
        """
        self._setup_url_browser(*args, **kwargs)
        if platform.system() == "Linux":
            kwargs["options"] = self._get_browser_linux_options(*args, **kwargs)
        logger.info("browser: " + self.browser)
        logger.info("url: " + self.url)
        if self.added_options:
            logger.info(self.added_options)
        browser_management = BrowserManagementKeywords(self)
        browser_management.open_browser(*args, **kwargs)

    def _get_browser_linux_options(self, *args, **kwargs):
        """
        Adds linux options for browser execution in docker / linux
        :param args: Place arguments
        :param kwargs: Keyword arguments dict
        :return: browser options to be added for docker execution
        """
        if "chrome" in self.browser.lower():
            return self._get_chrome_linux_options(*args, **kwargs)

    def _get_chrome_linux_options(self, *args, **kwargs):
        """
        Adds linux options for chrome browser execution in docker / linux
        :param args: Place arguments
        :param kwargs: Keyword arguments dict
        :return: browser options to be added for docker execution for chrome
        """
        if len(args) > 6:
            options = args[6]
        else:
            options = kwargs.get("options", None)
        if not options:
            options = selenium.webdriver.ChromeOptions()
            options.add_argument('--headless')
            options.add_argument('--no-sandbox')
            options.add_argument('--disable-dev-shm-usage')
            self.added_options = "Adding options --headless, --no-sandbox, --disable-dev-shm-usage"
        return options

    @staticmethod
    def _get_browser_information(browser_name, browser_details):
        """
        Based on browser name fetches browser version and driver version information
        :param browser_name: Name of the browser
        :param browser_details: Dictionary to be populated with details from browser information
        """
        driver = None
        if browser_name.lower().startswith("chrome"):
            chrome_options = webdriver.chrome.options.Options()
            chrome_options.add_argument("--headless")
            if platform.system() == "Linux":
                chrome_options.add_argument("--no-sandbox")
                chrome_options.add_argument("--disable-dev-shm-usage")
                logger.info("Added chrome linux options for linux sandbox, %s", str(chrome_options))
            driver = webdriver.Chrome(options=chrome_options)
            browser_details["driver_version"] = driver.capabilities["chrome"]["chromedriverVersion"]
            if "(" in browser_details["driver_version"]:
                browser_details["driver_version"] = \
                    browser_details["driver_version"].split("(", 1)[0]
            browser_version = driver.capabilities.get('version')
            if not browser_version:
                browser_version = driver.capabilities.get("browserVersion")
            browser_details["browser_version"] = browser_version
        elif browser_name.lower().startswith("firefox"):
            firefox_options = webdriver.firefox.options.Options()
            firefox_options.add_argument('-headless')
            driver = webdriver.Firefox(options=firefox_options)
            browser_details["browser_version"] = driver.capabilities["browserVersion"]
            browser_details["driver_version"] = driver.capabilities['moz:geckodriverVersion']
        elif browser_name.lower().startswith("ie"):
            ie_options = webdriver.ie.options.Options()
            ie_options.add_argument('-headless')
            driver = webdriver.Ie(options=ie_options)
            browser_details["browser_version"] = driver.capabilities["browserVersion"]
        elif browser_name.lower().startswith("phantomjs"):
            driver = webdriver.PhantomJS()
            browser_details["browser_version"] = driver.capabilities["version"]
            browser_details["driver_version"] = driver.capabilities['driverVersion']
        if driver:
            driver.close()

    def get_browser_metadata(self, browser="chrome", reload=False):
        """
        Fetches browser metadata information
        :param browser: Name of the browser for which information is fetched
        :param reload: Re-read the metadata based on the browser
        :return: Browser metadata information, dict of format
                    {"browser_version": browser version value,
                     "driver_version": driver version value}
        """
        if not (self.browser_details and not reload):
            try:
                self.browser_details = {"browser_version": "",
                                        "driver_version": ""}
                BrowserSupport._get_browser_information(browser, self.browser_details)
            except (TypeError, NameError):
                pass
        return self.browser_details
