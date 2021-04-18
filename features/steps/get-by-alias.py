
from steps.execution import call_method
from steps.steps import *
import traceback

@then('"{user_name}" creates "{obj_from_alias_ref}" of class "{classname}" using alias "{alias}"')
@given('"{user_name}" creates "{obj_from_alias_ref}" of class "{classname}" using alias "{alias}"')
@when('"{user_name}" creates "{obj_from_alias_ref}" of class "{classname}" using alias "{alias}"')
def step_impl(context, user_name, obj_from_alias_ref, classname, alias):
    test_user = get_or_create_user(user_name)
    cls_module = "test_namespace.classes"
    if '.' in classname:
        cls_module_and_name = classname.split('.')
        cls_module = f"test_namespace.{cls_module_and_name[0]}"
        classname = cls_module_and_name[1]
    test_user.user_objects[obj_from_alias_ref] = call_method(test_user, classname, cls_module, 'get_by_alias', alias)

@then('"{user_name}" checks that there is no object of class "{classname}" with alias "{alias}"')
@given('"{user_name}" checks that there is no object of class "{classname}" with alias "{alias}"')
@when('"{user_name}" checks that there is no object of class "{classname}" with alias "{alias}"')
def step_impl(context, user_name, classname, alias):
    test_user = get_or_create_user(user_name)
    exception_produced = False
    cls_module = "test_namespace.classes"
    if '.' in classname:
        cls_module_and_name = classname.split('.')
        cls_module = f"test_namespace.{cls_module_and_name[0]}"
        classname = cls_module_and_name[1]
    try:
        call_method(test_user, classname, cls_module, 'get_by_alias', alias)
    except:
        exception_produced = True
    assert exception_produced is True

@then('"{user_name}" deletes alias "{alias}" from object "{obj_ref}"')
@given('"{user_name}" deletes alias "{alias}" from object "{obj_ref}"')
@when('"{user_name}" deletes alias "{alias}" from object "{obj_ref}"')
def step_impl(context, user_name, alias, obj_ref):
    test_user = get_or_create_user(user_name)
    test_user.user_objects[obj_ref].delete_alias()