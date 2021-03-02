from steps.steps import *

@given('"{user_name}" creates "{obj_version_ref}" object as a version of "{obj_ref}" object')
@when('"{user_name}" creates "{obj_version_ref}" object as a version of "{obj_ref}" object')
@then('"{user_name}" creates "{obj_version_ref}" object as a version of "{obj_ref}" object')
def step_impl(context, user_name, obj_version_ref, obj_ref):
    from storage import api
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    version_id, dest_backend_id = obj.new_version()
    version_obj = api.getByID(f"{version_id}:{dest_backend_id}:{obj.get_class_id()}")
    test_user.user_objects[obj_version_ref] = version_obj

@given('"{user_name}" consolidates "{obj_version_ref}" version object')
@when('"{user_name}" consolidates "{obj_version_ref}" version object')
@then('"{user_name}" consolidates "{obj_version_ref}" version object')
def step_impl(context, user_name, obj_version_ref):
    test_user = get_or_create_user(user_name)
    version_obj = test_user.user_objects[obj_version_ref]
    version_obj.consolidate_version()
