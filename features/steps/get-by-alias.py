
from steps.execution import call_method
from steps.steps import *

@then('"{user_name}" creates "{obj_from_alias_ref}" of class "{classname}" using alias "{alias}"')
@given('"{user_name}" creates "{obj_from_alias_ref}" of class "{classname}" using alias "{alias}"')
@when('"{user_name}" creates "{obj_from_alias_ref}" of class "{classname}" using alias "{alias}"')
def step_impl(context, user_name, obj_from_alias_ref, classname, alias):
    test_user = get_or_create_user(user_name)
    test_user.user_objects[obj_from_alias_ref] = call_method(test_user, classname, 'get_by_alias', alias)

@then('"{user_name}" checks that there is no object of class "{classname}" with alias "{alias}"')
@given('"{user_name}" checks that there is no object of class "{classname}" with alias "{alias}"')
@when('"{user_name}" checks that there is no object of class "{classname}" with alias "{alias}"')
def step_impl(context, user_name, classname, alias):
    test_user = get_or_create_user(user_name)
    exception_produced = False
    try:
        call_method(test_user, classname, 'get_by_alias', alias)
    except:
        exception_produced = True
    assert exception_produced == True