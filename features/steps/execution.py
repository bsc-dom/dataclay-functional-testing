import traceback

from dataclay import DataClayObject

from steps.steps import *

@given('"{user_name}" creates "{obj_ref}" object of class "{classname}" with constructor params "{params}"')
@when('"{user_name}" creates "{obj_ref}" object of class "{classname}" with constructor params "{params}"')
@then('"{user_name}" creates "{obj_ref}" object of class "{classname}" with constructor params "{params}"')
def create_obj_step_impl(context, user_name, obj_ref, classname, params):
    test_user = get_or_create_user(user_name)
    cls_module = "test_namespace.classes"
    if '.' in classname:
        cls_module_and_name = classname.split('.')
        cls_module = f"test_namespace.{cls_module_and_name[0]}"
        classname = cls_module_and_name[1]
    test_user.user_objects[obj_ref] = call_method(test_user, classname, cls_module, '__init__', params)

@given('"{user_name}" creates "{obj_ref}" object of class "{classname}"')
@when('"{user_name}" creates "{obj_ref}" object of class "{classname}"')
@then('"{user_name}" creates "{obj_ref}" object of class "{classname}"')
def step_impl(context, user_name, obj_ref, classname):
    create_obj_step_impl(context, user_name, obj_ref, classname, "")

@given('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}" and checks that result is "{check_result}"')
@when('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}" and checks that result is "{check_result}"')
@then('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}" and checks that result is "{check_result}"')
def exec_step_impl(context, user_name, method_name, params, obj_ref, check_result):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    result = call_method(test_user, type(obj).__name__, type(obj).__module__, method_name, params, obj)
    print(f"Checking result {result} is equals to {check_result}")
    assert str(result) == check_result

@given('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}" and store result into "{result_ref}" variable')
@when('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}" and store result into "{result_ref}" variable')
@then('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}" and store result into "{result_ref}" variable')
def exec_step_impl(context, user_name, method_name, params, obj_ref, result_ref):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    test_user.user_objects[result_ref] = call_method(test_user, type(obj).__name__, type(obj).__module__, method_name, params, obj)

@given('"{user_name}" runs "{method_name}" method in object "{obj_ref}" and checks that result is "{check_result}"')
@when('"{user_name}" runs "{method_name}" method in object "{obj_ref}" and checks that result is "{check_result}"')
@then('"{user_name}" runs "{method_name}" method in object "{obj_ref}" and checks that result is "{check_result}"')
def step_impl(context, user_name, method_name, obj_ref, check_result):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    result = call_method(test_user, type(obj).__name__, type(obj).__module__, method_name, "", obj)
    print(f"Checking result {result} is equals to {check_result}")
    assert str(result) == check_result

@given('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}"')
@when('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}"')
@then('"{user_name}" runs "{method_name}" method with params "{params}" in object "{obj_ref}"')
def step_impl(context, user_name, method_name, params, obj_ref):
    check_result = ""
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    result = call_method(test_user, type(obj).__name__, type(obj).__module__, method_name, params, obj)
    print(f"Checking result {result} is equals to {check_result}")
    assert str(result) == check_result

def call_method(test_user, classname, module, method_name, theparams, instance_self=None):

    if theparams == "":
        params = list()
    else:
        params = theparams.split(' ')

    from typing import get_type_hints
    actual_args = dict()
    cls = getattr(importlib.import_module(f"{module}"), classname)
    if instance_self is None:
        method_to_call = getattr(cls, method_name)
    else:
        method_to_call = getattr(instance_self, method_name)
    hints = get_type_hints(method_to_call)
    import uuid
    # ignore self parameter
    idx = -1
    for key in method_to_call.__code__.co_varnames:
        if idx >= 0 and idx < len(params):
            cur_arg = params[idx]
            param_type = type(cur_arg)
            if cur_arg.startswith("obj_"):
                actual_args[key] = test_user.user_objects[cur_arg]
            elif cur_arg.startswith("null"):
                actual_args[key] = None
            elif cur_arg.startswith("dataclayid_"):
                actual_args[key] = test_user.user_objects[cur_arg]
            elif cur_arg.startswith("execid_"):
                actual_args[key] = test_user.user_objects[cur_arg]
            elif key in hints and param_type != hints[key]:
                # cast string to type
                hint_type = hints[key]
                print(f"Casting {param_type} to {hint_type}")
                actual_args[key] = hints[key](cur_arg)
            else:
                print(f"Not casting {cur_arg} to {param_type}")
                actual_args[key] = cur_arg
        idx = idx + 1

    print(f"Calling method {method_name} with args {actual_args}")
    result = None
    if method_name == "__init__":
        result = cls(**actual_args)
    else:
        result = method_to_call(**actual_args)
    if result is None:
        result = ""
    print(f"Returning result {result}")
    return result
