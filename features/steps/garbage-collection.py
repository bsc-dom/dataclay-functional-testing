
from steps.execution import call_method
from steps.steps import *

@then('"{user_name}" checks that object with id "{obj_id_ref}" exists in dataClay')
@given('"{user_name}" checks that object with id "{obj_id_ref}" exists in dataClay')
@when('"{user_name}" checks that object with id "{obj_id_ref}" exists in dataClay')
def step_impl(context, user_name, obj_id_ref):
    test_user = get_or_create_user(user_name)
    obj_id = test_user.user_objects[obj_id_ref]
    from dataclay import api
    exists = api.getRuntime().exists_in_dataclay(obj_id)
    assert exists is True

@then('"{user_name}" checks that object with id "{obj_id_ref}" does not exist in dataClay')
@given('"{user_name}" checks that object with id "{obj_id_ref}" does not exist in dataClay')
@when('"{user_name}" checks that object with id "{obj_id_ref}" does not exist in dataClay')
def step_impl(context, user_name, obj_id_ref):
    test_user = get_or_create_user(user_name)
    obj_id = test_user.user_objects[obj_id_ref]
    from dataclay import api
    exists = api.getRuntime().exists_in_dataclay(obj_id)
    assert exists is False

@then('"{user_name}" checks that number of objects in dataClay is {num_objs_check}')
@given('"{user_name}" checks that number of objects in dataClay is {num_objs_check}')
@when('"{user_name}" checks that number of objects in dataClay is {num_objs_check}')
def step_impl(context, user_name, num_objs_check):
    test_user = get_or_create_user(user_name)
    from dataclay import api
    num_objs = api.get_num_objects()
    print(f"Found {num_objs} objects in dataClay")
    assert int(num_objs_check) == num_objs

@then('"{user_name}" detaches object "{obj_ref}" from session')
@given('"{user_name}" detaches object "{obj_ref}" from session')
@when('"{user_name}" detaches object "{obj_ref}" from session')
def step_impl(context, user_name, obj_ref):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    obj.session_detach()