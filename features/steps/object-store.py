from steps.steps import *
import importlib

@given('"{user_name}" runs dcPut for object "{obj_ref}" with alias = "{alias}", backend name = "{backend_name}" and recursive = "{recursive}"')
@then('"{user_name}" runs dcPut for object "{obj_ref}" with alias = "{alias}", backend name = "{backend_name}" and recursive = "{recursive}"')
@when('"{user_name}" runs dcPut for object "{obj_ref}" with alias = "{alias}", backend name = "{backend_name}" and recursive = "{recursive}"')
def dc_put_step_impl(context, user_name, obj_ref, alias, backend_name, recursive):

    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    thealias = alias
    if alias == "null":
        thealias = None
    backend_id = None
    if backend_name != "null":
        from dataclay import api
        backend_id = api.get_backend_id_by_name(backend_name)
    rec = True
    if recursive == "False":
        rec = False
    obj.dc_put(alias=thealias, backend_id=backend_id, recursive=rec)


@given('"{user_name}" runs dcPut for object "{obj_ref}" with alias "{alias}"')
@then('"{user_name}" runs dcPut for object "{obj_ref}" with alias "{alias}"')
@when('"{user_name}" runs dcPut for object "{obj_ref}" with alias "{alias}"')
def step_impl(context, user_name, obj_ref, alias):
    dc_put_step_impl(context, user_name, obj_ref, alias, "null", "True")


@given('"{user_name}" runs dcPut for object "{obj_ref}" with alias = "{alias}" and backend name = "{backend_name}"')
@then('"{user_name}" runs dcPut for object "{obj_ref}" with alias = "{alias}" and backend name = "{backend_name}"')
@when('"{user_name}" runs dcPut for object "{obj_ref}" with alias = "{alias}" and backend name = "{backend_name}"')
def step_impl(context, user_name, obj_ref, alias, backend_name):
    dc_put_step_impl(context, user_name, obj_ref, alias, backend_name, "True")


@given('"{user_name}" runs dcUpdate in object "{obj_ref}" with "{obj_orig_ref}" parameter')
@then('"{user_name}" runs dcUpdate in object "{obj_ref}" with "{obj_orig_ref}" parameter')
@when('"{user_name}" runs dcUpdate in object "{obj_ref}" with "{obj_orig_ref}" parameter')
def step_impl(context, user_name, obj_ref, obj_orig_ref):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    orig_obj = test_user.user_objects[obj_orig_ref]
    obj.dc_update(orig_obj)


@given('"{user_name}" runs dcClone in object "{obj_ref}" and store result into "{obj_clone_ref}"')
@then('"{user_name}" runs dcClone in object "{obj_ref}" and store result into "{obj_clone_ref}"')
@when('"{user_name}" runs dcClone in object "{obj_ref}" and store result into "{obj_clone_ref}"')
def step_impl(context, user_name, obj_ref, obj_clone_ref):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    clone_obj = obj.dc_clone()
    test_user.user_objects[obj_clone_ref] = clone_obj