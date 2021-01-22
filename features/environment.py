# USE: behave -D debug         (to enable  debug-logging)
# USE: behave -D debug=yes     (to enable  debug-logging)
# USE: behave -D debug=no      (to disable debug-logging)
from behave import *
BEHAVE_DEBUG_LOGGING = True
BEHAVE_DEBUG_ON_ERROR = False
import allure
from steps.steps import *
import os

def setup_debug_logging(userdata):
    global BEHAVE_DEBUG_LOGGING
    global BEHAVE_DEBUG_ON_ERROR
    BEHAVE_DEBUG_LOGGING = userdata.getbool("debug")
    BEHAVE_DEBUG_ON_ERROR = userdata.getbool("BEHAVE_DEBUG_ON_ERROR")

def before_all(context):
    setup_debug_logging(context.config.userdata)
    if BEHAVE_DEBUG_LOGGING:
        os.environ['DEBUG'] = 'True'
        # clean logs

def before_feature(context, feature):
    pass

def before_step(context, step):
    pass

def after_step(context, step):
    if BEHAVE_DEBUG_ON_ERROR and step.status == "failed":
        # -- ENTER DEBUGGER: Zoom in on failure location.
        # NOTE: Use IPython debugger, same for pdb (basic python debugger).
        import ipdb
        ipdb.post_mortem(step.exc_traceback)

def after_feature(context, feature):
    pass

def before_scenario(context, scenario):
    clean_scenario(context)

def after_scenario(context, scenario):
    if BEHAVE_DEBUG_LOGGING:
        save_logs(context)
    clean_scenario(context)

def after_all(context):
    if BEHAVE_DEBUG_LOGGING:
        save_logs(context)